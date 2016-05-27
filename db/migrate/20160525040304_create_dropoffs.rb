class CreateDropoffs < ActiveRecord::Migration
  def change
    create_table :dropoffs do |t|
      t.integer   "company_id",     null: false
      t.integer   "restaurant_id",  null: false
      t.integer   "user_count",     null: false, default: 0
      t.timestamps null: false
    end
  end
end
