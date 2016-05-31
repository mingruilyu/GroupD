class ChangeShippingDeliverytimeType < ActiveRecord::Migration
  def change
    change_column :shippings, :estimated_arrival_at, :integer
  end
end
