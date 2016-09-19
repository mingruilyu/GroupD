class OrderRemodel < ActiveRecord::Migration
  def change
    remove_column :caterings, :expire
    add_column :caterings, :available_until, :datetime, null: false 
    add_column :caterings, :order_count, :integer, null: false, default: 0
    remove_column :shippings, :customer_count
    remove_column :combos, :count
  end
end
