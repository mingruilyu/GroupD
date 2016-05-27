class ChangeShippingColumn < ActiveRecord::Migration
  def change
    rename_column :shippings, :channel_id, :dropoff_id
  end
end
