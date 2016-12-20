class CreateCaterings < ActiveRecord::Migration
  def change
    create_table :caterings do |t|
      t.integer :combo_id, null: false
      t.integer :shipping_id, null: false
      t.timestamps null: false
    end
  end
end
