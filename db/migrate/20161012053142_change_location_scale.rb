class ChangeLocationScale < ActiveRecord::Migration
  def change
    change_column :locations, :coord_x, :decimal, scale: 7, precision: 10
    change_column :locations, :coord_y, :decimal, scale: 7, precision: 10
    rename_column :locations, :coord_x, :lat
    rename_column :locations, :coord_y, :lng
  end
end
