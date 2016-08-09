class SpecifyCustomerAndMerchantId < ActiveRecord::Migration
  def change
    rename_column :carts, :account_id, :customer_id
    rename_column :restaurants, :account_id, :merchant_id
  end
end
