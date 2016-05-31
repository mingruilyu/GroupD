class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float "coord_x", null: false
      t.float "coord_y", null: false
      t.string "address", null: false
      t.timestamps null: false
    end
  end
end
