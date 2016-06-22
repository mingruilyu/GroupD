class ChangeCustomerIdToAccountId < ActiveRecord::Migration
  def change
    rename_column :carts, :customer_id, :account_id
    rename_column :cart_items, :customer_id, :account_id
  end
end
