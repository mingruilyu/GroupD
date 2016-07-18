class RenameAccountId < ActiveRecord::Migration
  def change
    rename_column :payments, :account_id, :customer_id
  end
end
