class RemoveDebtIdFromTransaction < ActiveRecord::Migration
  def change
    remove_column :transactions, :debt_id
  end
end
