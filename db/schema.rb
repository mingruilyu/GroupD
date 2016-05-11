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

ActiveRecord::Schema.define(version: 20160505060914) do

  create_table "cellphones", force: :cascade do |t|
    t.string   "number",               limit: 20, default: "", null: false
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token",   limit: 10, default: "", null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "cellphones", ["number"], name: "index_cellphones_on_number", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string "name", limit: 100, null: false
  end

  add_index "cities", ["name"], name: "index_cities_on_name", unique: true, using: :btree

  create_table "dishes", force: :cascade do |t|
    t.string   "name",        limit: 255,                           default: ""
    t.decimal  "price",                     precision: 8, scale: 2, default: 0.0
    t.string   "image_url",   limit: 255,                           default: ""
    t.text     "desc",        limit: 65535
    t.integer  "count",       limit: 4,                             default: 0
    t.integer  "merchant_id", limit: 4,                             default: 0
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  create_table "merchants", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                    null: false
    t.string   "encrypted_password",     limit: 255, default: "",                    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "restaurant_name",        limit: 255, default: ""
    t.string   "owner_name",             limit: 255, default: ""
    t.string   "cellphone",              limit: 255, default: ""
    t.string   "addr",                   limit: 255, default: ""
    t.float    "coord_x",                limit: 24,  default: 0.0
    t.float    "coord_y",                limit: 24
    t.integer  "category_id",            limit: 4,   default: 0
    t.string   "certificate_url",        limit: 255, default: ""
    t.datetime "order_start_at",                     default: '2016-04-20 06:46:29'
    t.datetime "order_end_at",                       default: '2016-04-20 06:46:30'
    t.datetime "est_delivery_at",                    default: '2016-04-20 06:46:30'
    t.float    "ave_price",              limit: 24,  default: 0.0
    t.string   "image",                  limit: 255, default: ""
    t.integer  "city_id",                limit: 4,   default: 0
    t.integer  "state_id",               limit: 4,   default: 0
  end

  add_index "merchants", ["email"], name: "index_merchants_on_email", unique: true, using: :btree
  add_index "merchants", ["reset_password_token"], name: "index_merchants_on_reset_password_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",  null: false
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
    t.float    "current_coord_x",        limit: 24,  default: 0.0
    t.float    "current_coord_y",        limit: 24,  default: 0.0
    t.integer  "city_id",                limit: 4,   default: 1,   null: false
    t.integer  "cellphone_id",           limit: 4,   default: 0,   null: false
    t.integer  "company_id",             limit: 4
    t.string   "username",               limit: 255, default: ""
  end

  add_index "users", ["cellphone_id"], name: "index_users_on_cellphone_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
