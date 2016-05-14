class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.integer   :quantity,  null: false,  default: 1
      t.integer   :user_id,   limit: 11,    null: false
      t.integer   :cart_id,   limit: 11,    null: false
      t.integer   :dish_id,   limit: 11,    null: false
      t.timestamps null: false
    end
  end
end
