class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
			t.string 			"name",					null: false
			t.integer			"category_id",	null: false, default: 1
			t.string			"address"
			t.integer			"city_id",			null: false
			t.float				"coord_x",			null: false, default: 0
			t.float				"coord_y",			null: false, default: 0
			t.string			"image_url"
			t.integer			"owner_id",			null: false
    end
  end
end
