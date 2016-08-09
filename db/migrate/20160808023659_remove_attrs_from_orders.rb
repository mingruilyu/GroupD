class RemoveAttrsFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :payment_id
    remove_column :orders, :total_price
  end
end
