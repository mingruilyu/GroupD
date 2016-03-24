class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
			t.integer  "user_id", limit: 8, default: 0, null: false
			t.integer  "food_id", limit: 8, default: 0, null: false
			t.text 		 "content", limit: 500
			t.datetime "created_at", null:false
			t.datetime "updated_at", null:false
    end
  end
end
