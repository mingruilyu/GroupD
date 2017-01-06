class Order < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :customer
  belongs_to :shipping
  belongs_to :payment
  belongs_to :food

  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true, 
    message: I18n.t('error.ORDER_INVALID_QUANTITY')}
  validates :restaurant_id, :customer_id, presence: true
  validate :shipping_available

  TAX_RATE = 0.1
  SINGLE_ORDER_QUANTITY_LIMIT = 10

  STATUS_CHECKOUT = 0
  STATUS_UNCHECKOUT = 1
  STATUS_PENDING = 2
  STATUS_CANCELED = 3
  STATUS_DELIVERED = 4
  STATUS_FULFILLED = 5

  scope :by_shipping, ->(shipping) { where shipping_id: shipping }
  scope :by_customer, ->(customer) { where customer_id: customer }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_food, ->(food) { where(food_id: food) }
  scope :uncheckout_by_customer, ->(customer) {
    self.by_status(STATUS_UNCHECKOUT).merge(self.by_customer customer)
  }
  scope :checkout_by_customer, ->(customer) {
    self.by_status(STATUS_CHECKOUT).merge(self.by_customer customer) }
  scope :fulfilled_by_customer, ->(customer) {
    self.by_status(STATUS_FULFILLED).merge(self.by_customer customer) }
  scope :cancellable_by_shipping, ->(shipping) {
    self.by_shipping(shipping).merge(self.where(status: [
      STATUS_CHECKOUT, STATUS_PENDING, STATUS_UNCHECKOUT])) }
  scope :checkout_by_shipping, ->(shipping) { 
    self.by_shipping(shipping).merge(self.by_status(STATUS_CHECKOUT))}
  scope :delivered_by_shipping, ->(shipping) { 
    self.by_shipping(shipping).merge(self.by_status(STATUS_DELIVERED))}
  scope :count_order_by_shipping, ->(shipping) {
    self.where(status: [STATUS_CHECKOUT, STATUS_DELIVERED]).group(
      :status).count }

  def self.check!(shipping, food, quantity)

  end

  def self.place!(shipping, food, quantity, customer, payment)
    subtotal = quantity * food.price
    order = Order.new quantity: quantity, food_id: food.id,
      shipping_id: shipping.id, customer_id: customer.id, 
      restaurant_id: food.restaurant_id, tax: subtotal * TAX_RATE,
      payment_id: payment.id
    ActiveRecord::Base.transaction do
      # shipping has to be locked, we cannot allow order to be placed
      # after the shipping is canceled
      shipping.lock! 'LOCK IN SHARE MODE'
      food.lock!
      # Check whether time is over the food's order ddl or required 
      # quantity is over the food's quota. If not, place order; 
      # otherwise, raise a pending order request.
      if food.L_orderable? shipping, quantity
        order.status = STATUS_CHECKOUT
        food.L_increment_order_count quantity
        payment.T_pay food.restaurant.merchant_id, order.total_price
        order.save!
      elsif food.L_requestable?
        order.status = STATUS_PENDING
        order.save!
      else
        order.errors.add :status, message: I18n.t(
          'error.FOOD_NOT_ORDERABLE')
        raise Exceptions::NotEffective.new(order)
      end
    end
    order
  end

  def approve!
    ActiveRecord::Base.transaction do
      food = self.food
      food.lock!
      self.lock!
      unless self.L_pending?
        self.errors.add :status, I18n.t(
          'error.NOT_PENDING_FOR_APPROVAL')
        raise Exceptions::NotEffective.new(self)
      end
      self.update_attribute :status, STATUS_CHECKOUT
      self.payment.T_pay self.restaurant.merchant_id, self.total_price
      food.L_increment_order_count self.quantity
    end
  end

  def cancel!
    ActiveRecord::Base.transaction do
      self.lock!
      if self.L_cancellable?
        if self.L_checkout?
          food = self.food
          food.lock!
          food.L_decrement_order_count self.quantity
          # only use record cash for refund 
          self.payment.T_refund self.restaurant.merchant_id,
            self.total_price
        end
        self.update_attribute :status, STATUS_CANCELED
      else
        self.errors['status'] = I18n.t 'error.ORDER_NOT_CANCELLABLE'
        raise Exceptions::NotEffective.new(self)
      end
    end
  end

  def pickup!
    ActiveRecord::Base.transaction do
      self.lock!
      unless self.L_checkout?
        self.errors[:status] = I18n.t 'error.PICKUP_ORDER_NOT_CHECKOUT'
        raise Exceptions::NotEffective.new(self)
      end
      self.update_attributes! status: STATUS_DELIVERED
    end
  end

  def subtotal
    @subtotal ||= self.quantity * self.food.price
  end

  def total_price
    self.subtotal + self.tax
  end

  def as_json(options={})
    super only: [:id, :quantity, :special_instruction, :shipping_id, 
      :food_id, :status]
  end

  protected

    def L_cancellable?
      self.status == STATUS_CHECKOUT || self.status == STATUS_PENDING\
        || self.status == STATUS_UNCHECKOUT
    end

    def L_checkout?
      self.status == STATUS_CHECKOUT
    end

    def L_canceled?
      self.status == STATUS_CANCELED
    end

    def L_pending?
      self.status == STATUS_PENDING
    end

  private

    def shipping_available
      # Shipping should also be available for pending orders
      self.errors[:base] = I18n.t 'error.SHIPPING_EXPIRED' if \
        self.shipping.nil? || self.shipping.L_expired?
    end
end
