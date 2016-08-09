class Catering < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :combo

  validates_associated :combo

  attr_accessor :building_list
  attr_accessor :delivery_date
  attr_accessor :delivery_time
  attr_accessor :available_until

  scope :active, -> { joins(:shipping).merge(Shipping.active) }
  scope :by_restaurant, ->(restaurant_id) \
    { joins(:shipping).merge(Shipping.by_restaurant(restaurant_id)) }
  scope :active_by_restaurant, ->(restaurant_id) \
    { joins(:shipping).merge(
        Shipping.by_restaurant(restaurant_id).active) }
  scope :active_by_building, ->(building_id) \
    { joins(:shipping).merge(
        Shipping.by_building(building_id).active) }


  def combo_name
    self.combo.name
  end

  def restaurant_name
    self.combo.restaurant.name
  end

  def restaurant_id
    self.combo.restaurant.id
  end

  def order_count
    self.shipping.customer_count
  end
end
