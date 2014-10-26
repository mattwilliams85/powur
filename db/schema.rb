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

ActiveRecord::Schema.define(version: 20141023092335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "hstore"

  create_table "bonus_levels", id: false, force: true do |t|
    t.integer "bonus_id",                                      null: false
    t.integer "level",                            default: 0,  null: false
    t.decimal "amounts",  precision: 5, scale: 5, default: [], null: false, array: true
  end

  create_table "bonus_payment_orders", id: false, force: true do |t|
    t.integer "bonus_payment_id", null: false
    t.integer "order_id",         null: false
  end

  create_table "bonus_payments", force: true do |t|
    t.string   "pay_period_id",                                      null: false
    t.integer  "bonus_id",                                           null: false
    t.integer  "user_id",                                            null: false
    t.decimal  "amount",        precision: 10, scale: 2,             null: false
    t.integer  "status",                                 default: 1, null: false
    t.integer  "pay_as_rank",                            default: 1, null: false
    t.datetime "created_at",                                         null: false
  end

  create_table "bonus_plans", force: true do |t|
    t.string  "name",        null: false
    t.integer "start_year"
    t.integer "start_month"
  end

  add_index "bonus_plans", ["start_year", "start_month"], name: "index_bonus_plans_on_start_year_and_start_month", unique: true, using: :btree

  create_table "bonus_sales_requirements", id: false, force: true do |t|
    t.integer "bonus_id",                  null: false
    t.integer "product_id",                null: false
    t.integer "quantity",   default: 1,    null: false
    t.boolean "source",     default: true, null: false
  end

  create_table "bonuses", force: true do |t|
    t.integer  "bonus_plan_id",                                               null: false
    t.string   "type",                                                        null: false
    t.string   "name",                                                        null: false
    t.integer  "schedule",                                    default: 2,     null: false
    t.integer  "use_rank_at",                                 default: 2,     null: false
    t.integer  "achieved_rank_id"
    t.integer  "max_user_rank_id"
    t.integer  "min_upline_rank_id"
    t.boolean  "compress",                                    default: false, null: false
    t.decimal  "flat_amount",        precision: 10, scale: 2, default: 0.0,   null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  create_table "customer_notes", force: true do |t|
    t.integer  "customer_id",              null: false
    t.integer  "author_id",                null: false
    t.string   "note",        limit: 1000
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
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

  create_table "distributions", force: true do |t|
    t.string  "pay_period_id",                          null: false
    t.integer "user_id",                                null: false
    t.decimal "amount",        precision: 10, scale: 2, null: false
  end

  add_index "distributions", ["pay_period_id", "user_id"], name: "index_distributions_on_pay_period_id_and_user_id", unique: true, using: :btree

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

  create_table "order_totals", force: true do |t|
    t.string  "pay_period_id",                 null: false
    t.integer "user_id",                       null: false
    t.integer "product_id",                    null: false
    t.integer "personal",          default: 0, null: false
    t.integer "group",                         null: false
    t.integer "personal_lifetime", default: 0, null: false
    t.integer "group_lifetime",                null: false
  end

  add_index "order_totals", ["pay_period_id", "user_id", "product_id"], name: "idx_order_totals_composite_key", unique: true, using: :btree

  create_table "orders", force: true do |t|
    t.integer  "product_id",              null: false
    t.integer  "user_id",                 null: false
    t.integer  "customer_id",             null: false
    t.integer  "quote_id"
    t.integer  "quantity",    default: 1
    t.datetime "order_date",              null: false
    t.integer  "status",      default: 1, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "orders", ["quote_id"], name: "index_orders_on_quote_id", unique: true, using: :btree

  create_table "pay_periods", id: false, force: true do |t|
    t.string   "id",                                      null: false
    t.string   "type",                                    null: false
    t.date     "start_date",                              null: false
    t.date     "end_date",                                null: false
    t.datetime "calculated_at"
    t.datetime "distributed_at"
    t.decimal  "total_volume",   precision: 10, scale: 2
    t.decimal  "total_bonus",    precision: 10, scale: 2
    t.decimal  "total_breakage", precision: 10, scale: 2
  end

  create_table "products", force: true do |t|
    t.string   "name",                                  null: false
    t.integer  "bonus_volume",                          null: false
    t.integer  "commission_percentage", default: 100,   null: false
    t.boolean  "distributor_only",      default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "qualifications", force: true do |t|
    t.string  "type",                                null: false
    t.string  "path",            default: "default", null: false
    t.integer "time_period",                         null: false
    t.integer "quantity",        default: 1,         null: false
    t.integer "max_leg_percent"
    t.integer "rank_id"
    t.integer "product_id",                          null: false
  end

  add_index "qualifications", ["product_id"], name: "index_qualifications_on_product_id", using: :btree
  add_index "qualifications", ["rank_id"], name: "index_qualifications_on_rank_id", using: :btree

  create_table "quote_field_lookups", force: true do |t|
    t.integer "quote_field_id", null: false
    t.string  "value",          null: false
    t.integer "identifier",     null: false
  end

  add_index "quote_field_lookups", ["quote_field_id"], name: "index_quote_field_lookups_on_quote_field_id", using: :btree

  create_table "quote_fields", force: true do |t|
    t.integer "product_id",                 null: false
    t.string  "name",                       null: false
    t.integer "data_type",  default: 1,     null: false
    t.boolean "required",   default: false, null: false
  end

  add_index "quote_fields", ["product_id"], name: "index_quote_fields_on_product_id", using: :btree

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

  create_table "rank_achievements", force: true do |t|
    t.string   "pay_period_id"
    t.integer  "user_id",       null: false
    t.integer  "rank_id",       null: false
    t.string   "path",          null: false
    t.datetime "achieved_at",   null: false
  end

  add_index "rank_achievements", ["pay_period_id", "user_id", "rank_id", "path"], name: "rank_achievements_comp_key_with_pp", unique: true, where: "(pay_period_id IS NOT NULL)", using: :btree
  add_index "rank_achievements", ["user_id", "rank_id", "path"], name: "rank_achievements_comp_key_without_pp", unique: true, order: {"user_id"=>:desc}, where: "(pay_period_id IS NULL)", using: :btree

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

  create_table "user_activities", force: true do |t|
    t.integer  "user_id"
    t.datetime "event_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event"
  end

  create_table "user_overrides", force: true do |t|
    t.integer "user_id",                 null: false
    t.integer "kind",                    null: false
    t.hstore  "data",       default: {}
    t.date    "start_date"
    t.date    "end_date"
  end

  create_table "users", force: true do |t|
    t.string   "email",                            null: false
    t.string   "encrypted_password",               null: false
    t.string   "first_name",                       null: false
    t.string   "last_name",                        null: false
    t.hstore   "contact",             default: {}
    t.string   "url_slug"
    t.string   "reset_token"
    t.datetime "reset_sent_at"
    t.string   "roles",               default: [],              array: true
    t.integer  "upline",              default: [],              array: true
    t.integer  "lifetime_rank"
    t.integer  "organic_rank"
    t.string   "rank_path"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "sponsor_id"
    t.hstore   "utilities"
    t.hstore   "profile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["sponsor_id"], name: "index_users_on_sponsor_id", using: :btree
  add_index "users", ["upline"], name: "index_users_on_upline", using: :gin
  add_index "users", ["url_slug"], name: "index_users_on_url_slug", unique: true, using: :btree

  create_table "utilities", id: false, force: true do |t|
    t.integer "id",   null: false
    t.string  "name", null: false
  end

  add_foreign_key "bonus_levels", "bonuses", name: "bonus_levels_bonus_id_fk"

  add_foreign_key "bonus_payment_orders", "bonus_payments", name: "bonus_payment_orders_bonus_payment_id_fk"
  add_foreign_key "bonus_payment_orders", "orders", name: "bonus_payment_orders_order_id_fk"

  add_foreign_key "bonus_payments", "bonuses", name: "bonus_payments_bonus_id_fk"
  add_foreign_key "bonus_payments", "pay_periods", name: "bonus_payments_pay_period_id_fk"
  add_foreign_key "bonus_payments", "ranks", name: "bonus_payments_pay_as_rank_fk", column: "pay_as_rank"
  add_foreign_key "bonus_payments", "users", name: "bonus_payments_user_id_fk"

  add_foreign_key "bonus_sales_requirements", "bonuses", name: "bonus_sales_requirements_bonus_id_fk"
  add_foreign_key "bonus_sales_requirements", "products", name: "bonus_sales_requirements_product_id_fk"

  add_foreign_key "bonuses", "bonus_plans", name: "bonuses_bonus_plan_id_fk"
  add_foreign_key "bonuses", "ranks", name: "bonuses_achieved_rank_id_fk", column: "achieved_rank_id"
  add_foreign_key "bonuses", "ranks", name: "bonuses_max_user_rank_id_fk", column: "max_user_rank_id"
  add_foreign_key "bonuses", "ranks", name: "bonuses_min_upline_rank_id_fk", column: "min_upline_rank_id"

  add_foreign_key "customer_notes", "users", name: "customer_notes_author_id_fk", column: "author_id"

  add_foreign_key "distributions", "pay_periods", name: "distributions_pay_period_id_fk"
  add_foreign_key "distributions", "users", name: "distributions_user_id_fk"

  add_foreign_key "invites", "users", name: "invites_sponsor_id_fk", column: "sponsor_id"
  add_foreign_key "invites", "users", name: "invites_user_id_fk"

  add_foreign_key "order_totals", "pay_periods", name: "order_totals_pay_period_id_fk"
  add_foreign_key "order_totals", "products", name: "order_totals_product_id_fk"
  add_foreign_key "order_totals", "users", name: "order_totals_user_id_fk"

  add_foreign_key "orders", "customers", name: "orders_customer_id_fk"
  add_foreign_key "orders", "products", name: "orders_product_id_fk"
  add_foreign_key "orders", "quotes", name: "orders_quote_id_fk"
  add_foreign_key "orders", "users", name: "orders_user_id_fk"

  add_foreign_key "qualifications", "products", name: "qualifications_product_id_fk"
  add_foreign_key "qualifications", "ranks", name: "qualifications_rank_id_fk"

  add_foreign_key "quote_field_lookups", "quote_fields", name: "quote_field_lookups_quote_field_id_fk"

  add_foreign_key "quote_fields", "products", name: "quote_fields_product_id_fk"

  add_foreign_key "quotes", "customers", name: "quotes_customer_id_fk"
  add_foreign_key "quotes", "products", name: "quotes_product_id_fk"
  add_foreign_key "quotes", "users", name: "quotes_user_id_fk"

  add_foreign_key "rank_achievements", "pay_periods", name: "rank_achievements_pay_period_id_fk"
  add_foreign_key "rank_achievements", "ranks", name: "rank_achievements_rank_id_fk"
  add_foreign_key "rank_achievements", "users", name: "rank_achievements_user_id_fk"

  add_foreign_key "user_overrides", "users", name: "user_overrides_user_id_fk"

  add_foreign_key "users", "ranks", name: "users_lifetime_rank_fk", column: "lifetime_rank"
  add_foreign_key "users", "ranks", name: "users_organic_rank_fk", column: "organic_rank"
  add_foreign_key "users", "users", name: "users_sponsor_id_fk", column: "sponsor_id"

end
