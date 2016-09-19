class AddRestaurantIdToCombo < ActiveRecord::Migration
  def change
    add_column :combos, :restaurant_id, :integer, null: false
  end
end
