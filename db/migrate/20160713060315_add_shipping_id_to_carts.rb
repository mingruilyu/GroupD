class AddShippingIdToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :shipping_id, :integer
  end
end
