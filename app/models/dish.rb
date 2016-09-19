class Dish < ActiveRecord::Base
  belongs_to  :restaurant
  has_many    :cart_items

  validates :name, presence: true, uniqueness: { scope: :restaurant }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :image_url, presence: true

  validates_associated :restaurant

end
