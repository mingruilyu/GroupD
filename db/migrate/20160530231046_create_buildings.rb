class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string "name", limit: 255, null: false, default: ""
      t.integer "location_id", null: false
      t.integer "company_id", null: false
      t.timestamps null: false
    end
  end
end
