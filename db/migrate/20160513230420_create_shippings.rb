class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.integer     :status,  limit: 1,   null: false,  default: 0
      t.float       :coord_x
      t.float       :coord_y
      t.float       :price
      t.integer     :channel_id,  limit: 11
      t.timestamps null: false
    end
  end
end
