class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :catering

  validates_associated :catering
  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true }
  validate :catering_should_not_expire

  attr_accessor :expected_order_id

  def belongs_to?(order)
    self.order_id == order.id
  end

  def as_json(options={})
    super only: [:quantity, :special_instruction, :catering_id,
      :order_id]
  end

  private
    def catering_should_not_expire
      raise Exceptions::CateringExpired unless self.catering.can_order?
    end
end
