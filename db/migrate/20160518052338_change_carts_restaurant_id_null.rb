class ChangeCartsRestaurantIdNull < ActiveRecord::Migration
  def change
    change_column_null :carts, :restaurant_id, true
  end
end
