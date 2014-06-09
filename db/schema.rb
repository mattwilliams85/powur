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

ActiveRecord::Schema.define(version: 20140604062729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "customers", force: true do |t|
    t.string   "url_slug",                  null: false
    t.integer  "status",        default: 0
    t.string   "first_name",                null: false
    t.string   "last_name",                 null: false
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "utility"
    t.integer  "rate_schedule"
    t.integer  "kwh"
    t.string   "roof_material"
    t.integer  "roof_age"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "promoter_id",               null: false
  end

  add_index "customers", ["promoter_id"], name: "index_customers_on_promoter_id", using: :btree
  add_index "customers", ["url_slug"], name: "index_customers_on_url_slug", unique: true, using: :btree

  create_table "invites", id: false, force: true do |t|
    t.string   "id",         null: false
    t.string   "email",      null: false
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "phone"
    t.datetime "expires",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "invitor_id", null: false
    t.integer  "invitee_id"
  end

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",              null: false
    t.string   "encrypted_password", null: false
    t.string   "first_name",         null: false
    t.string   "last_name",          null: false
    t.string   "phone"
    t.string   "zip"
    t.string   "url_slug"
    t.string   "reset_token"
    t.datetime "reset_sent_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "invitor_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitor_id"], name: "index_users_on_invitor_id", using: :btree
  add_index "users", ["url_slug"], name: "index_users_on_url_slug", unique: true, using: :btree

  add_foreign_key "customers", "users", name: "customers_promoter_id_fk", column: "promoter_id"

  add_foreign_key "invites", "users", name: "invites_invitee_id_fk", column: "invitee_id"
  add_foreign_key "invites", "users", name: "invites_invitor_id_fk", column: "invitor_id"

  add_foreign_key "users", "users", name: "users_invitor_id_fk", column: "invitor_id"

end
