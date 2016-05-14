class Dish < ActiveRecord::Base
    belongs_to :restaurant
    validates :name, :price, :desc, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0.01 }
    validates :name, uniqueness: true
end
