class AddColumnsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :category_id, :integer, default: 0
    add_column :merchants, :certificate_url, :string, default: ""
    add_column :merchants, :order_start_at, :datetime, default: Time.now
    add_column :merchants, :order_end_at, :datetime, default: Time.now
    add_column :merchants, :est_delivery_at, :datetime, default: Time.now
    add_column :merchants, :ave_price, :float, default: 0.0
    add_column :merchants, :image, :string, default: ""
    add_column :merchants, :city_id, :integer, default: 0
    add_column :merchants, :state_id, :integer, default: 0
  end
end
