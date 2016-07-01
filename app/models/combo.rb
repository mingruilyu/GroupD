class Combo < Dish
  has_many :caterings, dependent: :delete_all
  has_many :shippings, through: :caterings

  scope :active, -> { joins(:caterings).merge(Catering.active) }
  scope :by_restaurant, ->(restaurant_id) \
    { joins(:caterings).merge(Catering.by_restaurant(restaurant_id)) }
  scope :active_by_restaurant, ->(restaurant_id) \
    { joins(:caterings).merge(Catering.active_by_restaurant(restaurant_id)) }

end
