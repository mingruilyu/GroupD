class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :menus, :mechant_id, :merchant_id
  end
end
