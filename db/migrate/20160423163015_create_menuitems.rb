class CreateMenuitems < ActiveRecord::Migration
  def change
    create_table :menuitems do |t|
      t.integer :dish_id
      t.integer :menu_id

      t.timestamps null: false
    end
  end
end
