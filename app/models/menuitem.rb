class Menuitem < ActiveRecord::Base
    belongs_to :menu
    belongs_to :dish
    validates :dish_id, :menu_id, presence: true
end
