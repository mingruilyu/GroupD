class AddStatusToRestaurant < ActiveRecord::Migration
  def change
    add_column :caterings, :status, :integer, limit: 1, null: false, default: 0
    add_column :restaurants, :status, :integer, limit: 1, null: false, default: 0
  end
end
