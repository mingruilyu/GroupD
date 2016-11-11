class Shipping < ActiveRecord::Base
  belongs_to :coordinate
  has_one :catering

  scope :not_done, -> { where('status != ?', STATUS_DONE) }

  STATUS_WAITING    = 0
  STATUS_DEPART     = 1
  STATUS_ARRIVE     = 2
  STATUS_PICKING_UP = 3
  STATUS_DONE       = 4

  def active?
    self.status == STATUS_WAITING
  end

  def done?
    self.status == STATUS_DONE
  end

  def update_status!
    case self.status 
    when STATUS_WAITING
      self.update_attribute :status, STATUS_DEPART
    when STATUS_DEPART
      self.update_attribute :status, STATUS_ARRIVE
    when STATUS_ARRIVE
      self.update_attribute :status, STATUS_PICKING_UP
    when STATUS_PICKING_UP
      self.fulfill!
    end
  end

  def fulfill!
    orders = Order.where shipping_id: self.id, 
      status: Order::STATUS_CHECKOUT
    Shipping.transaction do
      self.update_attribute :status, STATUS_DONE
      self.catering.T_fulfill!
      orders.each do |order|
        order.lock!
        order.T_fulfill!
      end
    end
  end
end
