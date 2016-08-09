class Dish < ActiveRecord::Base
  belongs_to  :restaurant
  has_many    :cart_items

  validates :name, presence: true, uniqueness: { scope: :restaurant }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :image_url, presence: true

  validates_associated :restaurant

  TYPE_COMBO = 'Combo'
  TYPE_DISH = 'Dish'
  
  def is_dish?
    self.type == TYPE_DISH
  end

  def is_combo?
    self.type == TYPE_COMBO
  end

  private
end
