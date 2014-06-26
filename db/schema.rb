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

ActiveRecord::Schema.define(version: 20140625072238) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "hstore"

  create_table "certifications", force: true do |t|
    t.string "title", null: false
  end

  create_table "customers", force: true do |t|
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invites", id: false, force: true do |t|
    t.string   "id",         null: false
    t.string   "email",      null: false
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "phone"
    t.datetime "expires",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "sponsor_id", null: false
    t.integer  "user_id"
  end

  create_table "products", force: true do |t|
    t.string   "name",                                                        null: false
    t.decimal  "commissionable_volume", precision: 8, scale: 2,               null: false
    t.integer  "commission_percentage",                         default: 100, null: false
    t.string   "quote_data",                                    default: [],               array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qualification_paths", force: true do |t|
    t.string "title", null: false
  end

  create_table "qualifications", force: true do |t|
    t.string  "type",             null: false
    t.integer "period"
    t.integer "quantity"
    t.integer "max_leg_percent"
    t.integer "path_id",          null: false
    t.integer "rank_id",          null: false
    t.integer "certification_id"
    t.integer "product_id"
  end

  add_index "qualifications", ["certification_id"], name: "index_qualifications_on_certification_id", using: :btree
  add_index "qualifications", ["path_id"], name: "index_qualifications_on_path_id", using: :btree
  add_index "qualifications", ["product_id"], name: "index_qualifications_on_product_id", using: :btree
  add_index "qualifications", ["rank_id"], name: "index_qualifications_on_rank_id", using: :btree

  create_table "quotes", force: true do |t|
    t.string   "url_slug",                 null: false
    t.hstore   "data",        default: {}, null: false
    t.integer  "customer_id",              null: false
    t.integer  "product_id",               null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "quotes", ["customer_id"], name: "index_quotes_on_customer_id", using: :btree
  add_index "quotes", ["product_id"], name: "index_quotes_on_product_id", using: :btree
  add_index "quotes", ["url_slug"], name: "index_quotes_on_url_slug", unique: true, using: :btree
  add_index "quotes", ["user_id"], name: "index_quotes_on_user_id", using: :btree

  create_table "ranks", id: false, force: true do |t|
    t.integer "id",    null: false
    t.string  "title", null: false
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
    t.string   "email",                           null: false
    t.string   "encrypted_password",              null: false
    t.string   "first_name",                      null: false
    t.string   "last_name",                       null: false
    t.hstore   "contact",            default: {}
    t.string   "url_slug"
    t.string   "reset_token"
    t.datetime "reset_sent_at"
    t.string   "roles",              default: [],              array: true
    t.integer  "upline",             default: [],              array: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "sponsor_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["sponsor_id"], name: "index_users_on_sponsor_id", using: :btree
  add_index "users", ["upline"], name: "index_users_on_upline", using: :gin
  add_index "users", ["url_slug"], name: "index_users_on_url_slug", unique: true, using: :btree

  add_foreign_key "invites", "users", name: "invites_sponsor_id_fk", column: "sponsor_id"
  add_foreign_key "invites", "users", name: "invites_user_id_fk"

  add_foreign_key "qualifications", "certifications", name: "qualifications_certification_id_fk"
  add_foreign_key "qualifications", "products", name: "qualifications_product_id_fk"
  add_foreign_key "qualifications", "qualification_paths", name: "qualifications_path_id_fk", column: "path_id"
  add_foreign_key "qualifications", "ranks", name: "qualifications_rank_id_fk"

  add_foreign_key "quotes", "customers", name: "quotes_customer_id_fk"
  add_foreign_key "quotes", "products", name: "quotes_product_id_fk"
  add_foreign_key "quotes", "users", name: "quotes_user_id_fk"

  add_foreign_key "users", "users", name: "users_sponsor_id_fk", column: "sponsor_id"

end
