class CreateDishes < ActiveRecord::Migration
  def change
    create_table :dishes do |t|
      t.string :name, default: ""
      t.float :price, default: 0.0
      t.string :image_url, default: ""
      t.text :desc
      t.integer :count, default: 0
      t.integer :merchant_id, default: 0

      t.timestamps null: false
    end
  end
end
