class RemoveTransactionIdFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :transaction_id
  end
end
