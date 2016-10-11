class ChangeComboPriceScale < ActiveRecord::Migration
  def change
    change_column :combos, :price, :decimal, scale: 2, precision: 8
  end
end
