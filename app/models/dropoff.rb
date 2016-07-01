class Dropoff < ActiveRecord::Base
  has_many :shippings
  belongs_to :building

  scope :by_restaurant, ->(restaurant) { where(restaurant_id: restaurant) }
  scope :by_building, ->(building) { where(building_id: building) }
end
