class RemoveAccountIdFromCartItems < ActiveRecord::Migration
  def change
    remove_column :cart_items, :account_id
  end
end
