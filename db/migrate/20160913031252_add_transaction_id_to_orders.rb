class AddTransactionIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :transaction_id, :integer, null: false
  end
end
