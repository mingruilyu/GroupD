class Shipping < ActiveRecord::Base
  belongs_to :coordinate
  belongs_to :restaurant
  belongs_to :building, -> { includes :company, :city }

  attr_accessor :delivery_date
  attr_accessor :delivery_time
  attr_accessor :asap

  STATUS_WAITING    = 0
  STATUS_DEPART     = 1
  STATUS_ARRIVE     = 2
  STATUS_PICKING_UP = 3
  STATUS_DONE       = 4

  SHIPPING_DEADLINE_BUFFER_TIME = 100

  SHIPPING_COMBO_PRICE = 0

  scope :active, -> { where(status: STATUS_WAITING) }
  scope :by_restaurant, ->(restaurant_id) \
    { where(restaurant_id: restaurant_id) }
  scope :by_building, ->(building_id) \
    { where(building_id: building_id) }

  def self.calculate_shipping_price(des_location, src_location)
    10
  end

  def same_time?(another_shipping)
    self.estimated_arrival_at == another_shiping.estimated_arrival_at
  end

  def same_date?(another_shipping)
    self.estimated_arrival_at.to_date == 
      another_shipping.estimated_arrival_at.to_date
  end

  def set_delivery_time(date, time_int, asap)
    if asap.present?
      self.estimated_arrival_at = DateTime.now.advance(hour: 1)
    else 
      self.estimated_arrival_at = DateTime.now.beginning_of_day.change(
                                    day: date, 
                                    hour: time_int / 100,
                                    min: time_int % 100)
    end
  end

  def set_deadline(date, time_int)
    self.available_until = DateTime.now.beginning_of_day.change(
                                    day: date,
                                    hour: time_int / 100, 
                                    min: time_int % 100)
  end

  def active?
    self.status == STATUS_WAITING
  end
end
