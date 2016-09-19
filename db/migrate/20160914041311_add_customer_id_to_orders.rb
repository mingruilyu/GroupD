class AddCustomerIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_id, :integer, null:false
  end
end
