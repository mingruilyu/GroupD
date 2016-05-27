class ChangeColumnOfShippingAndCarts < ActiveRecord::Migration
  def change
    add_column :carts, :shipping_id, :integer, limit: 11, null: false
    remove_column :shippings, :cart_id
  end
end
