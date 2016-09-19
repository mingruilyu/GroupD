class AddRestaurantToCatering < ActiveRecord::Migration
  def change
    add_column :caterings, :restaurant_id, :integer, null: false
  end
end
