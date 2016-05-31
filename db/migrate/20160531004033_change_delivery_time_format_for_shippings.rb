class ChangeDeliveryTimeFormatForShippings < ActiveRecord::Migration
  def change
    change_column :shippings, :estimated_arrival_at, :datetime
  end
end
