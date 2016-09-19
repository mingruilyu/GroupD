class AddTotalPriceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :total_price, :decimal, null: false
  end
end
