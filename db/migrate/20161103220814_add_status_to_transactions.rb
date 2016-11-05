class AddStatusToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :status, :integer, limit: 1, null: false, default: 0
  end
end
