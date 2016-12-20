class RemodelCatering < ActiveRecord::Migration
  def change
    drop_table    :shippings
    rename_column :caterings, :shipping_id, :coordinate_id
    remove_column :caterings, :combo_id
    remove_column :caterings, :available_until
    remove_column :caterings, :order_count
  end
end
