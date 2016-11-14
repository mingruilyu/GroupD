class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :catering

  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true, 
    message: I18n.t('error.ORDER_INVALID_QUANTITY')}
  validate :catering_should_not_expire

  scope :by_catering, ->(catering) { where catering_id: catering } 
  scope :checked_by_catering, ->(catering) { 
    self.by_catering(catering).joins(:order).merge(Order.by_status(
      Order::STATUS_CHECKOUT))}
  scope :delivered_by_catering, ->(catering) { 
    self.by_catering(catering).joins(:order).merge(Order.by_status(
      Order::STATUS_DELIVERED))}

  attr_accessor :status
  STATUS_CHECKED = 0
  STATUS_DELIVERED = 1

  def belongs_to?(order)
    self.order_id == order.id
  end

  def as_json(options={})
    hash = super only: [:quantity, :special_instruction, :catering_id,
      :order_id]
    hash[:status] = self.status
    hash
  end

  private
    def catering_should_not_expire
      unless (self.catering.present? && self.catering.can_order?)
        self.errors.add :catering, I18n.t('error.ADD_EXPIRED_CATERING')
      end
    end
end
