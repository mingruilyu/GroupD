class ChangeDropoffIdToBuildingId < ActiveRecord::Migration
  def change
    rename_column :shippings, :dropoff_id, :building_id
  end
end
