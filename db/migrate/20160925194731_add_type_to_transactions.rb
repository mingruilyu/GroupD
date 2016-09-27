class AddTypeToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :type, :integer, limit: 1, default: 0, null: false
  end
end
