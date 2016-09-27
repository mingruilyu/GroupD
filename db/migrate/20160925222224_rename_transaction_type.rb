class RenameTransactionType < ActiveRecord::Migration
  def change
    rename_column :transactions, :type, :purpose
  end
end
