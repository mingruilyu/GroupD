class ChangeOrderAndShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :estimated_arrival_at, :datetime
    rename_column :orders, :dropoff_id, :shipping_id
  end
end
