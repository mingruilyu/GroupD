class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
			t.string			"name",			limit: 100, null: false
    end
		add_index "cities", ["name"], name: "index_cities_on_name", unique:true, using: :btree
  end
end
