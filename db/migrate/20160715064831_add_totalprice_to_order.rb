class AddTotalpriceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :total_price, :float, null: false, default: 0 
  end
end
