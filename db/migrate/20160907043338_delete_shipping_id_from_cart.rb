class DeleteShippingIdFromCart < ActiveRecord::Migration
  def change
    remove_column :carts, :shipping_id
  end
end
