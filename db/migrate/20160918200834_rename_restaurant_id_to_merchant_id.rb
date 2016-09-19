class RenameRestaurantIdToMerchantId < ActiveRecord::Migration
  def change
    rename_column :dropoffs, :restaurant_id, :merchant_id
  end
end
