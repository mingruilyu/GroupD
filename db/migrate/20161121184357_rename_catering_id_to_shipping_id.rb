class RenameCateringIdToShippingId < ActiveRecord::Migration
  def change
    rename_column :orders, :catering_id, :shipping_id
  end
end
