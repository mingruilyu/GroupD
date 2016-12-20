class AddOrderCountToCombo < ActiveRecord::Migration
  def change
    add_column :combos, :order_count, :integer, null: false, default: 0
  end
end
