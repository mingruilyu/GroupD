class ChangeFloatToDecimal < ActiveRecord::Migration
  def change
    change_column :debts, :amount, :decimal
    change_column :locations, :coord_x, :decimal
    change_column :locations, :coord_y, :decimal
    change_column :restaurants, :ave_price, :decimal
    change_column :shippings, :price, :decimal
    change_column :transactions, :amount, :decimal
  end
end
