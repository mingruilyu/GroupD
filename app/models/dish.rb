class Dish < ActiveRecord::Base
    belongs_to :merchant
    has_many :menuitems
    before_destroy :ensure_not_referenced_by_any_line_item
    validates :name, :price, :desc, :merchant_id, presence: true
    validates :price, numericality: {greater_than_or_equal_to: 0.01}
    validates :name, uniqueness: true

    private
        def ensure_not_referenced_by_any_line_item 
            if menuitems.empty?
                return true
            else
                errors.add(:base, 'Menu items present')
                return false
            end
        end
end
