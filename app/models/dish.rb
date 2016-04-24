class Dish < ActiveRecord::Base
    belongs_to :merchant
    belongs_to :menuitem
    validates :name, :price, :desc, :merchant_id, presence: true
    validates :price, numericality: {greater_than_or_equal_to: 0.01}
    validates :name, uniqueness: true
end
