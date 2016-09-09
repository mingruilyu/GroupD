class CreateCombos < ActiveRecord::Migration
  def change
    create_table :combos do |t|
      t.integer 'combo_item_id', null: false
      t.integer 'count', null: false, default: 0
      t.decimal 'price', null: false, default: 10
      t.timestamps null: false
    end
  end
end
