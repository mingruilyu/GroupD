class AddStatusToCombo < ActiveRecord::Migration
  def change
    add_column :combos, :status, :integer, limit: 1, null: false, default: 0
  end
end
