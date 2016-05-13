class ModifyMerchantTable < ActiveRecord::Migration
  def change
    rename_column :merchants, :image, :image_url
    remove_column :merchants, :order_start_at
    remove_column :merchants, :order_end_at
    remove_column :merchants, :est_delivery_at
    add_column    :merchants, :username, :string, limit: 255
  end
end
