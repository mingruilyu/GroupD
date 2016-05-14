class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.integer   :restaurant_id,   limit: 11,  null: false
      t.integer   :shipping_id,     limit: 11,  null: false
      t.integer   :status,          limit: 1,   null: false,  default: 0
      t.timestamps null: false
    end
  end
end
