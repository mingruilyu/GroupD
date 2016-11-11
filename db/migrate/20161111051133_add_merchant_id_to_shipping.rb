class AddMerchantIdToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :merchant_id, :integer
  end
end
