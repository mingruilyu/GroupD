class CreateCaterings < ActiveRecord::Migration
  def change
    create_table :caterings do |t|
      t.integer :shipping_id, null: false
      t.integer :customer_count, null: false, default: 0
      t.integer :dish_id, null: false

      t.timestamps null: false
    end
  end
end
