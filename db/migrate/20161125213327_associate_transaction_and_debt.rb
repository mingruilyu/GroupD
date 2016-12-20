class AssociateTransactionAndDebt < ActiveRecord::Migration
  def change
    add_column :orders, :transaction_id, :integer
    add_column :transactions, :debt_id, :integer
  end
end
