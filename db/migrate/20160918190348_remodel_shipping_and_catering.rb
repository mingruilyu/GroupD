class RemodelShippingAndCatering < ActiveRecord::Migration
  def change
    remove_column :shippings, :building_id
    remove_column :shippings, :public_visible
    rename_column :shippings, :restaurant_id, :catering_id
    add_column :caterings, :estimated_arrival_at, :datetime, null: false
    add_column :caterings, :building_id, :integer, null: false
  end
end
