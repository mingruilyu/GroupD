class AddRestaurantIdToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :restaurant_id, :integer
  end
end
