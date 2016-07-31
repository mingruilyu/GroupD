class AddStatusToDebts < ActiveRecord::Migration
  def change
    add_column :debts, :status, :boolean, null: false, default: false
  end
end
