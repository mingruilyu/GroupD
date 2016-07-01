class AddAvailabilityToShippings < ActiveRecord::Migration
  def change
    add_column :shippings, :available_until, :datetime, null: false
  end
end
