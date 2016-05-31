class AllEntityUseLocationAndCoordinate < ActiveRecord::Migration
  def change
   remove_column  :users, :current_coord_x
   remove_column  :users, :current_coord_y
   add_column     :users, :coordinate_id, :integer

   remove_column  :shippings, :coord_x
   remove_column  :shippings, :coord_y
   add_column     :shippings, :coordinate_id, :integer, null: false
   add_column     :shippings, :public_visible, :boolean, null: false, default: true

   rename_column  :dropoffs, :company_id, :building_id

   remove_column  :restaurants, :coord_x
   remove_column  :restaurants, :coord_y
   remove_column  :restaurants, :address
   add_column     :restaurants, :location_id, :integer, null: false

  end
end
