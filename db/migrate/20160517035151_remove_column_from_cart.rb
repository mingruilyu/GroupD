class RemoveColumnFromCart < ActiveRecord::Migration
  def change
    add_column  :carts, :shipping_id, :integer
    remove_column :carts, :shipping_id
  end
end
