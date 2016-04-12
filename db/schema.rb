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

ActiveRecord::Schema.define(version: 20160324063851) do

  create_table "cities", force: :cascade do |t|
    t.string "name", limit: 100, null: false
  end

  add_index "cities", ["name"], name: "index_cities_on_name", unique: true, using: :btree

  create_table "foods", force: :cascade do |t|
    t.string   "name",        limit: 255,                  null: false
    t.string   "image_url",   limit: 255,                  null: false
    t.integer  "store_id",    limit: 8,                    null: false
    t.float    "price",       limit: 24,    default: 10.0, null: false
    t.text     "description", limit: 65535
    t.float    "rate",        limit: 24,    default: 10.0, null: false
    t.datetime "update_at",                                null: false
    t.datetime "created_at",                               null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id",    limit: 8,     default: 0, null: false
    t.integer  "food_id",    limit: 8,     default: 0, null: false
    t.text     "content",    limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "stores", force: :cascade do |t|
    t.string  "name",        limit: 255,               null: false
    t.integer "category_id", limit: 4,   default: 1,   null: false
    t.string  "address",     limit: 255
    t.integer "city_id",     limit: 4,                 null: false
    t.float   "coord_x",     limit: 24,  default: 0.0, null: false
    t.float   "coord_y",     limit: 24,  default: 0.0, null: false
    t.string  "image_url",   limit: 255
    t.integer "owner_id",    limit: 4,                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.float    "current_coord_x",        limit: 24
    t.float    "current_coord_y",        limit: 24
    t.integer  "city_id",                limit: 4,   default: 1,  null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
