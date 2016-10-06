class AddStatusToDish < ActiveRecord::Migration
  def change
    add_column :dishes, :status, :integer, limit: 1, null: false, default: 0
  end
end
