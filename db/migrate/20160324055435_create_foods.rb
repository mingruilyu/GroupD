class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
		t.string 		"name", 			limit: 255, null: false
		t.string 		"image_url", 	null: false
		t.integer 	"store_id", 	limit: 8, null: false
		t.float 		"price",			default: 10, null: false, scale: 2  
		t.text 			"description"	
		t.float			"rate",				default: 10, null: false, scale: 1
		t.datetime	"update_at",  null: false
		t.datetime  "created_at", null: false
    end
  end
end
