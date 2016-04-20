class AddRestaurantNameToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :restaurant_name, :string, default: ""
  end
end
