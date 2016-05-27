class CreateDropOffs < ActiveRecord::Migration
  def change
    create_table :drop_offs do |t|
      t.integer   "restaurant_id",      limit: 11, null: false
      t.integer   "company_id",       limit: 11, null: false
      t.integer   "user_count",   limit: 11, null: false, default: 0
      t.timestamps null: false
    end
  end
end
