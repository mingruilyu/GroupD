class RemoveOpenAndCloseTimeFromRestaurant < ActiveRecord::Migration
  def change
    remove_column :restaurants, :open_at
    remove_column :restaurants, :close_at
  end
end
