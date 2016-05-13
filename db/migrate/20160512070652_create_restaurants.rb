class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.integer   :merchant_id,     null: false
      t.string    :name,            limit: 255,   null: false, default: ""
      t.string    :address,         null: false,  default: ""
      t.float     :coord_x
      t.float     :coord_y
      t.integer   :category_id,     null: false,  default: 0
      t.integer   :open_at,         null: false,  default: 900
      t.integer   :close_at,        null: false,  default: 2000
      t.float     :ave_price,       null: false,  default: 0.0
      t.string    :image_url,       limit: 255,   null: false,  default: ""
      t.string    :certificate_url, limit: 255,   null: false,  default: ""
      t.integer   :city_id,         limit: 11,    null: false,  default: 1
      t.timestamps null: false
    end
  end
end
