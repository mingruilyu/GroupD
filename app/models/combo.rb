class Combo < ActiveRecord::Base 
  has_many :combo_items, dependent: :delete_all

end
