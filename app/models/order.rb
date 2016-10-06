class Order < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :customer
  has_many :order_items, dependent: :delete_all

  TAX_RATE = 0.1
  STATUS_UNCHECKOUT = 0
  STATUS_CHECKOUT = 1
  STATUS_CANCEL = 2
  attr_accessor :payment_id

  scope :by_customer, ->(customer) { 
    includes(:order_items).where(customer_id: customer).where('status != ?', STATUS_UNCHECKOUT) }
  scope :by_status, ->(status) { where(status: status) }

  def taxes
    @taxes ||= self.subtotal * TAX_RATE
  end

  def calculate_bill
    self.total_price = self.subtotal + self.taxes
  end

  def checkout!(payment_id, customer_id)
    # Check whether any item in the order has expired. 
    if self.has_expired?
      self.order_items.clear
      raise Exceptions::StaleRecord.new(
        Message::Warning::ORDER_EXPIRED, :warning, :gone) 
    end

    Order.transaction do
      self.lock!
      self.L_check_empty
      self.calculate_bill
      merchant_id = self.restaurant.merchant_id
      # record transaction
      transaction = Transaction.create sender_id: customer_id,
        receiver_id: self.restaurant.merchant_id,
        amount: self.total_price, purpose: Transaction::TYPE_PAYMENT
      self.transaction_id = transaction.id
      self.payment_id = payment_id
      self.save!
      # process payment
      if self.payment_id == Payment::RECORD_CASH_ID
        Debt.T_add_debt merchant_id, customer_id, self.total_price
      else
        # Todo embed other online payment platform APIs
        # initiate transaction
        yield
      end
      
      count_update = self.summarize_catering_count_update 
      Catering.T_increase_order_count count_update
    end
  end

  def cancel customer_id
    Order.transaction do
      count_update = self.summarize_catering_count_update 
      Catering.T_decrease_order_count count_update
      self.lock!
      self.L_check_checkout
      self.update_attribute :status, STATUS_CANCEL
      merchant_id = self.restaurant.merchant_id
      Debt.T_pay_debt merchant_id, customer_id, self.total_price
      Transaction.create receiver_id: customer_id, 
        sender_id: merchant_id, amount: self.total_price, 
        purpose: Transaction::TYPE_REFUND
    end
  end

  def clear_items
    Order.transaction do
      self.lock!
      self.L_check_modifiable
      self.order_items.clear
      self.restaurant_id = nil
      self.save!
    end
  end

  def add_item(params, catering)
    Order.transaction do
      self.lock!
      self.L_check_modifiable
      # we should obtain a shared lock here in case that catering is 
      # being destroyed. 
      catering.lock! 'LOCK IN SHARE MODE'
      order_item = OrderItem.new(
        quantity:             params[:quantity].to_i,
        order_id:             self.id,
        catering_id:          catering.id,
        special_instruction:  params[:special_instruction]
      )
      order_item.save!
      self.L_update_order_restaurant catering
    end
  end

  def remove_item(item)
    Order.transaction do
      self.lock!
      self.L_check_modifiable
      item.destroy!
    end
  end

  def subtotal 
    if @subtotal.nil? 
      @subtotal = 0 
      self.order_items.each do |item| 
        @subtotal += item.catering.combo.price * item.quantity 
      end 
    end 
    @subtotal 
  end

  def has_expired?
    self.order_items.each do |item|
      return true unless (item.catering.present? && item.catering.can_order?)
    end
    return false
  end

  def as_json(options={})
    hash = {
      "restaurant_id": self.restaurant_id,
      "order_items": self.order_items.collect { |item| item.as_json }
    }
    if self.checked_out?
      hash["total_price"] = self.total_price.as_json
      hash["transaction_id"] = self.transaction_id
    end
    hash
  end

  def summarize_catering_count_update
    # Merge the same items and update in one go before transaction.
    count = {}
    self.order_items.each do |item|
      if count.has_key? item.catering_id
        count[item.catering_id] += item.quantity
      else
        count[item.catering_id] = item.quantity
      end
    end
    count
  end

  def L_update_order_restaurant(catering)
    if self.restaurant_id != catering.restaurant_id  
      unless self.restaurant_id.nil?
        self.order_items.clear
      end
      self.update_attribute :restaurant_id, catering.restaurant_id
    end
  end

  protected
    def L_check_modifiable
      raise Exceptions::BadRequest unless self.unchecked_out?
    end

    def L_check_empty
      raise Exceptions::NotEffective.new(
        Message::Warning::ORDER_EMPTY, :warning, :found) \
        if self.order_items.empty?
    end

    def L_check_checkout
      raise Exceptions::BadRequest unless self.checked_out?
    end

    def checked_out?
      self.status == STATUS_CHECKOUT
    end

    def canceled?
      self.status == STATUS_CANCEL
    end

    def unchecked_out?
      self.status == STATUS_UNCHECKOUT
    end
end
