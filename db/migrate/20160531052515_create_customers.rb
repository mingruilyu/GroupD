class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer "account_id", null: false
      t.integer "coordinate_id", null: false
      t.integer "building_id", null: false
      t.integer "city_id", null: false, default: 1
      t.timestamps null: false
    end
  end
end
