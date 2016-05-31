class AddCityIdAndUserCountToBuilding < ActiveRecord::Migration
  def change
    add_column :buildings, :user_count, :integer, null: false, default: 0
    add_column :buildings, :city_id, :integer, null: false, default: 1
  end
end
