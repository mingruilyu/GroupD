class Dish < ActiveRecord::Base
    belongs_to :merchant
    belongs_to :menuitem
end
