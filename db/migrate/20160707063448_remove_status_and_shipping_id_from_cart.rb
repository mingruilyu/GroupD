class RemoveStatusAndShippingIdFromCart < ActiveRecord::Migration
  def change
    remove_column :carts, :shipping_id
    remove_column :carts, :status
  end
end
