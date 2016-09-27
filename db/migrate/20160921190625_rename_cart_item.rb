class RenameCartItem < ActiveRecord::Migration
  def change
    rename_table :cart_items, :order_items
    remove_column :order_items, :cart_id
    rename_column :orders, :cart_id, :restaurant_id
  end
end
