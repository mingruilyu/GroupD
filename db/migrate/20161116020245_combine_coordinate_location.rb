class CombineCoordinateLocation < ActiveRecord::Migration
  def change
    rename_column :accounts, :coordinate_id, :location_id
    rename_column :caterings, :coordinate_id, :location_id
  end
end
