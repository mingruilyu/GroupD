class RenameMerchantIdInPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :merchant_id, :account_id
  end
end
