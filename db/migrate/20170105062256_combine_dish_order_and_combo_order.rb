class CombineDishOrderAndComboOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :combo_id, :food_id
    remove_column :orders, :dish_id
  end
end
