class RemoveColumnsFromShippings < ActiveRecord::Migration
  def change
    remove_column :shippings, :estimated_arrival_at
    remove_column :shippings, :available_until
  end
end
