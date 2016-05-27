class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer   "dropoff_id", null: false
      t.integer   "cart_id", null: false
      t.timestamps null: false
    end
  end
end
