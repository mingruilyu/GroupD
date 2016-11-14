class Order < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :customer
  belongs_to :shipping
  has_many :order_items, dependent: :delete_all

  TAX_RATE = 0.1
  SINGLE_ORDER_QUANTITY_LIMIT = 10

  STATUS_UNCHECKOUT = 0
  STATUS_CHECKOUT = 1
  STATUS_CANCEL = 2
  STATUS_FULFILLED = 3
  STATUS_DELIVERED = 4
  attr_accessor :payment_id

  scope :by_customer, ->(customer) { 
    includes(:order_items).where(customer_id: customer)\
      .where('status != ?', STATUS_UNCHECKOUT) }
  scope :by_status, ->(status) { where(status: status) }
  scope :checked_out, ->(customer) {
    self.by_status(STATUS_CHECKOUT).by_customer(customer) }
  scope :fulfilled, ->(customer) {
    self.by_status(STATUS_FULFILLED).by_customer(customer) }

  def self.active_order!(customer_id)
    Order.includes(:order_items).find_by_customer_id_and_status(
      customer_id, Order::STATUS_UNCHECKOUT) || \
      Order.create(customer_id: customer_id)
  end

  def taxes
    @taxes ||= self.subtotal * TAX_RATE
  end

  def calculate_bill
    self.total_price = self.subtotal + self.taxes
  end

  def checkout!(payment_id)
    # Check whether any item in the order has expired. 
    if self.has_expired?
      self.order_items.clear
      self.errors[:items] = I18n.t 'error.CHECKOUT_EXPIRED_ITEM'
      raise Exceptions::StaleRecord.new(self) 
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
      self.status = STATUS_CHECKOUT
      self.save!
      # process payment
      if self.payment_id == Payment::RECORD_CASH_ID
        Debt.T_add_debt merchant_id, self.customer_id, self.total_price
      else
        # Todo embed other online payment platform APIs
        # initiate transaction
        yield
      end
      
      count_update = self.summarize_catering_count_update 
      Catering.T_increase_order_count count_update
    end
  end

  def pickup!
    Order.transaction do
      self.lock!
      self.update_attribute :status, STATUS_DELIVERED
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

  def T_fulfill!
    self.lock!
    self.update_attribute :status, STATUS_FULFILLED
  end

  def clear_items
    Order.transaction do
      self.lock!
      self.L_check_modifiable
      self.order_items.clear
      self.restaurant_id = nil
      self.shipping_id = nil
      self.save!
    end
  end

  def add_item(quantity, special_instruction, catering)
    order_item = OrderItem.new(
      quantity:             quantity,
      order_id:             self.id,
      catering_id:          catering.id,
      special_instruction:  special_instruction
    )
    Order.transaction do
      self.lock!
      self.L_check_modifiable
      # we should obtain a shared lock here in case that catering is 
      # being destroyed. 
      catering.lock! 'LOCK IN SHARE MODE'
      order_item.save!
      self.L_update_restaurant catering.restaurant_id
      self.L_update_shipping catering.shipping_id
    end
    order_item
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
      catering = item.catering
      return true unless (catering.present? && catering.can_order?)
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

  def L_update_restaurant(restaurant_id)
    if self.restaurant_id != restaurant_id  
      unless self.restaurant_id.nil?
        self.order_items.clear
      end
      self.update_attribute :restaurant_id, restaurant_id
    end
  end

  def L_update_shipping(shipping_id)
    if self.shipping_id != shipping_id
      unless self.shipping_id.nil?
        self.order_items.clear
      end
      self.update_attribute :shipping_id, shipping_id
    end
  end

  protected
    def L_check_modifiable
      unless self.unchecked_out?
        self.errors[:status] = I18n.t 'error.CLEAR_CHECKOUT_ORDER'
        raise Exceptions::NotEffective.new(self)
      end
    end

    def L_check_empty
      if self.order_items.empty?
        self.errors[:status] = I18n.t 'error.CHECK_EMPTY_ORDER'
        raise Exceptions::NotEffective.new(self)
      end
    end

    def L_check_checkout
       unless self.checked_out?
        self.errors.add :base, 
          message: I18n.t('error.CANCEL_UNCHECKOUT_ORDER')
        raise Exceptions::NotEffective.new(self)
      end
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
