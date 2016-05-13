class RemoveColumnsFromMerchants < ActiveRecord::Migration
  def change
    remove_column :merchants, :restaurant_name
    remove_column :merchants, :addr
    remove_column :merchants, :certificate_url
    remove_column :merchants, :ave_price
    remove_column :merchants, :image_url
    remove_column :merchants, :city_id
    remove_column :merchants, :state_id
    remove_column :merchants, :coord_x
    remove_column :merchants, :coord_y
    remove_column :merchants, :category_id
  end
end
