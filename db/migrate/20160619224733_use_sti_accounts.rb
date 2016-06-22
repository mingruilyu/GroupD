class UseStiAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :account_type, :type
    add_column    :accounts, :building_id, :integer, null: true
    add_column    :accounts, :coordinate_id, :integer, null: true
  end
end
