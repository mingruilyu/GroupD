class RenameDishMerchantIdColumn < ActiveRecord::Migration
  def change
    rename_column :dishes, :merchant_id,  :restaurant_id
    add_column    :dishes, :is_combo, :boolean, default: false, null: false
    add_column    :dishes, :sold_out, :boolean, default: false, null: false 
  end
end
