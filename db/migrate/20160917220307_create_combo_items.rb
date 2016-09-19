class CreateComboItems < ActiveRecord::Migration
  def change
    create_table :combo_items do |t|
      t.integer 'dish_id', null: false
      t.integer 'combo_id', null: false
      t.timestamps null: false
    end
  end
end
