class Dish < ActiveRecord::Base
  belongs_to  :restaurant
  has_many    :cart_items
  validates :name, :price, :desc, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :name, uniqueness: { scope: :restaurant }

  DISH_COMBO = 'Combo'
  DISH_DISH = 'Dish'
  
  def is_dish?
    self.type == DISH_DISH
  end

  def is_combo?
    self.type == DISH_COMBO
  end
end
