class AddOrderIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :order_id, :integer, null: false
  end
end
