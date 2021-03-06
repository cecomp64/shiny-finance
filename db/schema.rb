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

ActiveRecord::Schema.define(version: 20140302062358) do

  create_table "actions", force: true do |t|
    t.string "name"
  end

  add_index "actions", ["name"], name: "index_actions_on_name", unique: true

  create_table "lots", force: true do |t|
    t.integer  "quantity_remaining", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "lots", ["user_id"], name: "index_lots_on_user_id"

  create_table "transactions", force: true do |t|
    t.date     "date"
    t.integer  "quantity"
    t.string   "symbol"
    t.text     "description"
    t.float    "price"
    t.float    "amount"
    t.float    "fees"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "action_id"
    t.integer  "lot_id"
  end

  add_index "transactions", ["lot_id"], name: "index_transactions_on_lot_id"
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
