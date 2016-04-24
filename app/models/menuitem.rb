class Menuitem < ActiveRecord::Base
    has_many :dishes
    validates :dish_id, :menu_id, presence: true
end
