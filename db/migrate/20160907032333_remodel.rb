class Remodel < ActiveRecord::Migration
  def change
    remove_column :caterings, :count
    remove_column :cart_items, :dish_id
    remove_column :dishes, :count
    remove_column :dishes, :sold_out
    remove_column :dishes, :type
  end
end
