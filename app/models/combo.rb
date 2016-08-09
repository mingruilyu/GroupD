class Combo < Dish
  has_many :caterings, dependent: :delete_all
  has_many :shippings, through: :caterings

  scope :active, -> { joins(caterings: :shipping).merge(
    Shipping.active) }
  scope :by_restaurant, ->(restaurant_id) \
    { joins(caterings: :shipping).merge(
        Shipping.by_restaurant(restaurant_id)) }
  scope :active_by_restaurant, ->(restaurant_id) \
    { joins(caterings: :shipping).merge(
        Shipping.by_restaurant(restaurant_id)).active }

  def active_shippings
    self.shippings.merge(Shipping.active)
  end

  def self.combo_default_name
    'COMBO' + Time.now.to_formatted_s(:number)
  end
end
