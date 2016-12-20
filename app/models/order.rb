class Order < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :customer
  belongs_to :shipping
  belongs_to :payment

  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true, 
    message: I18n.t('error.ORDER_INVALID_QUANTITY')}
  validates :restaurant_id, :customer_id, presence: true
  validate :shipping_has_not_expired

  TAX_RATE = 0.1
  SINGLE_ORDER_QUANTITY_LIMIT = 10

  STATUS_CHECKOUT = 0
  STATUS_UNCHECKOUT = 1
  STATUS_PENDING = 2
  STATUS_CANCEL = 3
  STATUS_DELIVERED = 4
  STATUS_FULFILLED = 5

  scope :by_shipping, ->(shipping) { where shipping_id: shipping }
  scope :by_customer, ->(customer) { where customer_id: customer }
  scope :by_status, ->(status) { where(status: status) }
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

  def cancel!
    ActiveRecord::Base.transaction do
      self.lock!
      if self.L_cancellable?
        if self.L_checkout?
          yield
          # only use record cash for refund 
          self.payment.T_refund self.restaurant.merchant_id,
            self.total_price
        end
        self.update_attribute :status, STATUS_CANCEL
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

  def total_price
    self.subtotal + self.tax
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
      self.status == STATUS_CANCEL
    end

    def L_pending?
      self.status == STATUS_PENDING
    end

  private

    def shipping_has_not_expired
      self.errors[:base] = I18n.t 'error.SHIPPING_EXPIRED' if \
        self.shipping.present? && self.shipping.L_expired?
    end
end
