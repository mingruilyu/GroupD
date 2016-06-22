class ChangeUserToCustomer < ActiveRecord::Migration
  def change
    rename_column :buildings, :user_count, :customer_count
    rename_column :cart_items, :user_id, :customer_id
    rename_column :carts, :user_id, :customer_id
    rename_column :shippings, :user_count, :customer_count
  end
end
