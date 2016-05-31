class Shipping < ActiveRecord::Base
  belongs_to :coordinate
  belongs_to :dropoff

  SHIPPING_WAITING    = 0
  SHIPPING_DEPART     = 1
  SHIPPING_ARRIVE     = 2
  SHIPPING_PICKING_UP = 3
  SHIPPING_DONE       = 4
end
