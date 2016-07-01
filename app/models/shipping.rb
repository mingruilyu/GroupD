class Shipping < ActiveRecord::Base
  belongs_to :coordinate
  belongs_to :dropoff

  attr_accessor :delivery_date
  attr_accessor :delivery_time
  attr_accessor :asap

  SHIPPING_WAITING    = 0
  SHIPPING_DEPART     = 1
  SHIPPING_ARRIVE     = 2
  SHIPPING_PICKING_UP = 3
  SHIPPING_DONE       = 4

  scope :active, -> { where(status: SHIPPING_WAITING) }
  scope :by_restaurant, ->(restaurant_id) \
    { joins(:dropoff).merge(Dropoff.by_restaurant(restaurant_id)) }
  scope :active_by_restaurant, ->(restaurant_id) \
    { joins(:dropoff).merge(Dropoff.by_restaurant(restaurant_id)).active }

  def self.calculate_shipping_price(des_location, src_location)
    10
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
end
