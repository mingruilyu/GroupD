class AddOrderCountToDish < ActiveRecord::Migration
  def change
    add_column :dishes, :order_count, :integer, null: false, default: 0
  end
end
