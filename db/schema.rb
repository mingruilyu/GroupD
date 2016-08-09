# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160808023659) do

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",  null: false
    t.string   "username",               limit: 255,               null: false
    t.integer  "cellphone_id",           limit: 4,                 null: false
    t.string   "encrypted_password",     limit: 255, default: "",  null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "type",                   limit: 255, default: "0", null: false
    t.integer  "building_id",            limit: 4
    t.integer  "coordinate_id",          limit: 4
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "buildings", force: :cascade do |t|
    t.string   "name",           limit: 255, default: "", null: false
    t.integer  "location_id",    limit: 4,                null: false
    t.integer  "company_id",     limit: 4,                null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "customer_count", limit: 4,   default: 0,  null: false
    t.integer  "city_id",        limit: 4,   default: 1,  null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "quantity",            limit: 4,     default: 1, null: false
    t.integer  "cart_id",             limit: 4,                 null: false
    t.integer  "dish_id",             limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "special_instruction", limit: 65535
    t.integer  "catering_id",         limit: 4
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "restaurant_id", limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "customer_id",   limit: 4,                 null: false
    t.integer  "shipping_id",   limit: 4
    t.boolean  "status",                  default: false, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "caterings", force: :cascade do |t|
    t.integer  "shipping_id", limit: 4,             null: false
    t.integer  "combo_id",    limit: 4,             null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "count",       limit: 4, default: 0, null: false
  end

  create_table "cellphones", force: :cascade do |t|
    t.string   "number",               limit: 20, default: "", null: false
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token",   limit: 10, default: "", null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name", limit: 100, null: false
  end

  add_index "cities", ["name"], name: "index_cities_on_name", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "debts", force: :cascade do |t|
    t.integer  "debtor_id",  limit: 4,                  null: false
    t.integer  "loaner_id",  limit: 4,                  null: false
    t.float    "amount",     limit: 24, default: 0.0,   null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "status",                default: false, null: false
  end

  create_table "dishes", force: :cascade do |t|
    t.string   "name",          limit: 255,                           default: ""
    t.decimal  "price",                       precision: 8, scale: 2, default: 0.0
    t.string   "image_url",     limit: 255,                           default: ""
    t.text     "desc",          limit: 65535
    t.integer  "count",         limit: 4,                             default: 0
    t.integer  "restaurant_id", limit: 4,                             default: 0
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.boolean  "sold_out",                                            default: false, null: false
    t.string   "type",          limit: 255
  end

  create_table "dropoffs", force: :cascade do |t|
    t.integer  "building_id",   limit: 4, null: false
    t.integer  "restaurant_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "locations", force: :cascade do |t|
    t.float    "coord_x",    limit: 24,  null: false
    t.float    "coord_y",    limit: 24,  null: false
    t.string   "address",    limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "shipping_id", limit: 4, null: false
    t.integer  "cart_id",     limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "customer_id",  limit: 4,                 null: false
    t.string   "payment_type", limit: 255, default: "0", null: false
    t.string   "method",       limit: 255, default: "",  null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "restaurants", force: :cascade do |t|
    t.integer  "merchant_id",     limit: 4,                  null: false
    t.string   "name",            limit: 255, default: "",   null: false
    t.integer  "category_id",     limit: 4,   default: 0,    null: false
    t.integer  "open_at",         limit: 4,   default: 900,  null: false
    t.integer  "close_at",        limit: 4,   default: 2000, null: false
    t.float    "ave_price",       limit: 24,  default: 0.0,  null: false
    t.string   "image_url",       limit: 255, default: "",   null: false
    t.string   "certificate_url", limit: 255, default: "",   null: false
    t.integer  "city_id",         limit: 4,   default: 1,    null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "location_id",     limit: 4,                  null: false
  end

  create_table "shippings", force: :cascade do |t|
    t.integer  "status",               limit: 1,  default: 0,    null: false
    t.float    "price",                limit: 24
    t.integer  "building_id",          limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "customer_count",       limit: 4,  default: 0,    null: false
    t.datetime "estimated_arrival_at"
    t.integer  "coordinate_id",        limit: 4
    t.boolean  "public_visible",                  default: true, null: false
    t.datetime "available_until",                                null: false
    t.integer  "restaurant_id",        limit: 4
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "sender_id",   limit: 4,                null: false
    t.integer  "receiver_id", limit: 4,                null: false
    t.float    "amount",      limit: 24, default: 0.0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

end
