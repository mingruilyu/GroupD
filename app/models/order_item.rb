class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :catering

  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true }
  validate :catering_should_not_expire
  validates_associated :catering, :order

  scope :by_catering, ->(catering) { where catering_id: catering } 
  scope :checked_by_catering, ->(catering) { 
    self.by_catering(catering).joins(:order).merge(Order.by_status(
      Order::STATUS_CHECKOUT))}

  def belongs_to?(order)
    self.order_id == order.id
  end

  def as_json(options={})
    super only: [:quantity, :special_instruction, :catering_id,
      :order_id]
  end

  private
    def catering_should_not_expire
      raise Exceptions::StaleRecord.new(
        Message::Error::CATERING_EXPIRED, :error, :found) unless \
        (self.catering.present? && self.catering.can_order?)
    end
end
