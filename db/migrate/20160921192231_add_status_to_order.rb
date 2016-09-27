class AddStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :status, :integer, limit: 1, null: false, default: 0
  end
end
