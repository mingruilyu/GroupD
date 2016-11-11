class AddShippingToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_id, :integer
    add_column :order_items, :dish_id, :integer
  end
end
