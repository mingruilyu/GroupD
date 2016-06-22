class ChangeRestaurantMerchantId < ActiveRecord::Migration
  def change
    rename_column :restaurants, :merchant_id, :account_id
  end
end
