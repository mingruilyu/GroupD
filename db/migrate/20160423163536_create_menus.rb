class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer :mechant_id, default: 0
      t.datetime :date,  default: Time.now

      t.timestamps null: false
    end
  end
end
