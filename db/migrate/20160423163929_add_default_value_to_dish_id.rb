class AddDefaultValueToDishId < ActiveRecord::Migration
  def change
    change_column :menuitems, :dish_id, :integer, default: 0
    change_column :menuitems, :menu_id, :integer, default: 0
  end
end
