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

ActiveRecord::Schema.define(version: 20150415072216) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "hstore"

  create_table "api_clients", force: :cascade do |t|
    t.string "secret", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string   "access_token", null: false
    t.string   "client_id",    null: false
    t.integer  "user_id"
    t.datetime "expires_at",   null: false
  end

  add_index "api_tokens", ["access_token"], name: "index_api_tokens_on_access_token", unique: true, using: :btree

  create_table "bonus_amounts", force: :cascade do |t|
    t.integer "bonus_id",                  null: false
    t.integer "level",        default: 0,  null: false
    t.integer "rank_path_id"
    t.decimal "amounts",      default: [], null: false, array: true
  end

  add_index "bonus_amounts", ["bonus_id"], name: "index_bonus_amounts_on_bonus_id", using: :btree

  create_table "bonus_payment_orders", id: false, force: :cascade do |t|
    t.integer "bonus_payment_id", null: false
    t.integer "order_id",         null: false
  end

  create_table "bonus_payments", force: :cascade do |t|
    t.string   "pay_period_id",                                      null: false
    t.integer  "bonus_id",                                           null: false
    t.integer  "user_id",                                            null: false
    t.decimal  "amount",        precision: 10, scale: 2,             null: false
    t.integer  "status",                                 default: 1, null: false
    t.integer  "pay_as_rank",                            default: 0, null: false
    t.datetime "created_at",                                         null: false
  end

  create_table "bonus_plans", force: :cascade do |t|
    t.string  "name",        null: false
    t.integer "start_year"
    t.integer "start_month"
  end

  add_index "bonus_plans", ["start_year", "start_month"], name: "index_bonus_plans_on_start_year_and_start_month", unique: true, using: :btree

  create_table "bonuses", force: :cascade do |t|
    t.integer  "bonus_plan_id",                                            null: false
    t.string   "type",                                   default: "Bonus", null: false
    t.string   "name",                                                     null: false
    t.integer  "schedule",                               default: 2,       null: false
    t.hstore   "meta_data",                              default: {}
    t.boolean  "compress",                               default: false,   null: false
    t.decimal  "flat_amount",   precision: 10, scale: 2, default: 0.0,     null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "product_id"
  end

  create_table "customer_notes", force: :cascade do |t|
    t.integer  "customer_id",              null: false
    t.integer  "author_id",                null: false
    t.string   "note",        limit: 1000
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "customers", force: :cascade do |t|
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

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "distributions", force: :cascade do |t|
    t.string  "pay_period_id",                          null: false
    t.integer "user_id",                                null: false
    t.decimal "amount",        precision: 10, scale: 2, null: false
  end

  add_index "distributions", ["pay_period_id", "user_id"], name: "index_distributions_on_pay_period_id_and_user_id", unique: true, using: :btree

  create_table "invites", force: :cascade do |t|
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

  create_table "lead_updates", force: :cascade do |t|
    t.integer  "quote_id",                  null: false
    t.string   "provider_uid",              null: false
    t.string   "status",                    null: false
    t.hstore   "contact",      default: {}
    t.hstore   "order_status", default: {}
    t.datetime "consultation"
    t.datetime "contract"
    t.datetime "installation"
    t.datetime "created_at",                null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_totals", force: :cascade do |t|
    t.string  "pay_period_id",                 null: false
    t.integer "user_id",                       null: false
    t.integer "product_id",                    null: false
    t.integer "personal",          default: 0, null: false
    t.integer "group",                         null: false
    t.integer "personal_lifetime", default: 0, null: false
    t.integer "group_lifetime",                null: false
  end

  add_index "order_totals", ["pay_period_id", "user_id", "product_id"], name: "idx_order_totals_composite_key", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
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

  create_table "pay_periods", force: :cascade do |t|
    t.string   "type",                                        null: false
    t.date     "start_date",                                  null: false
    t.date     "end_date",                                    null: false
    t.datetime "calculate_queued"
    t.datetime "calculate_started"
    t.datetime "calculated_at"
    t.datetime "distribute_queued"
    t.datetime "distribute_started"
    t.datetime "disbursed_at"
    t.decimal  "total_volume",       precision: 10, scale: 2
    t.decimal  "total_bonus",        precision: 10, scale: 2
    t.decimal  "total_breakage",     precision: 10, scale: 2
  end

  create_table "product_enrollments", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_enrollments", ["user_id", "product_id"], name: "index_product_enrollments_on_user_id_and_product_id", using: :btree

  create_table "product_receipts", force: :cascade do |t|
    t.integer "product_id",                              null: false
    t.integer "user_id",                                 null: false
    t.decimal "amount",         precision: 10, scale: 2, null: false
    t.string  "transaction_id",                          null: false
    t.string  "order_id",                                null: false
    t.string  "auth_code"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",                                             null: false
    t.integer  "bonus_volume",                                     null: false
    t.integer  "commission_percentage",            default: 100,   null: false
    t.boolean  "distributor_only",                 default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "sku"
    t.text     "description"
    t.boolean  "certifiable",                      default: false
    t.string   "image_original_path"
    t.string   "smarteru_module_id",    limit: 50
  end

  add_index "products", ["certifiable"], name: "index_products_on_certifiable", using: :btree

  create_table "qualifications", force: :cascade do |t|
    t.string  "type",                        null: false
    t.integer "time_period",                 null: false
    t.integer "quantity",        default: 1, null: false
    t.integer "max_leg_percent"
    t.integer "rank_id"
    t.integer "product_id",                  null: false
    t.integer "rank_path_id"
  end

  add_index "qualifications", ["product_id"], name: "index_qualifications_on_product_id", using: :btree
  add_index "qualifications", ["rank_id"], name: "index_qualifications_on_rank_id", using: :btree

  create_table "quote_field_lookups", force: :cascade do |t|
    t.integer "quote_field_id", null: false
    t.string  "value",          null: false
    t.string  "identifier",     null: false
    t.string  "group"
  end

  add_index "quote_field_lookups", ["quote_field_id"], name: "index_quote_field_lookups_on_quote_field_id", using: :btree

  create_table "quote_fields", force: :cascade do |t|
    t.integer "product_id",                 null: false
    t.string  "name",                       null: false
    t.integer "data_type",  default: 1,     null: false
    t.boolean "required",   default: false, null: false
  end

  add_index "quote_fields", ["product_id"], name: "index_quote_fields_on_product_id", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.string   "url_slug",                  null: false
    t.hstore   "data",         default: {}, null: false
    t.integer  "customer_id",               null: false
    t.integer  "product_id",                null: false
    t.integer  "user_id",                   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "submitted_at"
    t.string   "provider_uid"
  end

  add_index "quotes", ["customer_id"], name: "index_quotes_on_customer_id", using: :btree
  add_index "quotes", ["product_id"], name: "index_quotes_on_product_id", using: :btree
  add_index "quotes", ["url_slug"], name: "index_quotes_on_url_slug", unique: true, using: :btree
  add_index "quotes", ["user_id"], name: "index_quotes_on_user_id", using: :btree

  create_table "rank_achievements", force: :cascade do |t|
    t.string   "pay_period_id"
    t.integer  "user_id",       null: false
    t.integer  "rank_id",       null: false
    t.integer  "rank_path_id"
    t.datetime "achieved_at",   null: false
  end

  add_index "rank_achievements", ["pay_period_id", "user_id", "rank_id", "rank_path_id"], name: "rank_achievements_comp_key_with_pp", unique: true, where: "(pay_period_id IS NOT NULL)", using: :btree
  add_index "rank_achievements", ["user_id", "rank_id", "rank_path_id"], name: "rank_achievements_comp_key_without_pp", unique: true, order: {"user_id"=>:desc}, where: "(pay_period_id IS NULL)", using: :btree

  create_table "rank_paths", force: :cascade do |t|
    t.string  "name",                    null: false
    t.string  "description"
    t.integer "precedence",  default: 1, null: false
  end

  add_index "rank_paths", ["precedence"], name: "index_rank_paths_on_precedence", unique: true, using: :btree

  create_table "ranks", force: :cascade do |t|
    t.string "title", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "file_original_path"
    t.string   "file_type",           limit: 60
    t.string   "image_original_path"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resources", ["file_type", "is_public"], name: "index_resources_on_file_type_and_is_public", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "user_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "event_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event"
  end

  create_table "user_group_requirements", force: :cascade do |t|
    t.string  "user_group_id",             null: false
    t.integer "product_id",                null: false
    t.integer "event_type",                null: false
    t.integer "quantity",      default: 1, null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "title",       null: false
    t.string "description"
  end

  create_table "user_overrides", force: :cascade do |t|
    t.integer "user_id",                 null: false
    t.integer "kind",                    null: false
    t.hstore  "data",       default: {}
    t.date    "start_date"
    t.date    "end_date"
  end

  create_table "user_user_groups", id: false, force: :cascade do |t|
    t.integer "user_id",       null: false
    t.string  "user_group_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             null: false
    t.string   "encrypted_password",                null: false
    t.string   "first_name",                        null: false
    t.string   "last_name",                         null: false
    t.hstore   "contact",              default: {}
    t.string   "url_slug"
    t.string   "reset_token"
    t.datetime "reset_sent_at"
    t.string   "roles",                default: [],              array: true
    t.integer  "upline",               default: [],              array: true
    t.integer  "lifetime_rank"
    t.integer  "organic_rank"
    t.integer  "rank_path_id"
    t.integer  "sponsor_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.hstore   "profile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "remember_created_at"
    t.datetime "last_sign_in_at"
    t.string   "smarteru_employee_id"
    t.boolean  "moved"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["sponsor_id"], name: "index_users_on_sponsor_id", using: :btree
  add_index "users", ["upline"], name: "index_users_on_upline", using: :gin
  add_index "users", ["url_slug"], name: "index_users_on_url_slug", unique: true, using: :btree

  add_foreign_key "api_tokens", "api_clients", column: "client_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "bonus_amounts", "bonuses"
  add_foreign_key "bonus_amounts", "rank_paths"
  add_foreign_key "bonus_payment_orders", "bonus_payments"
  add_foreign_key "bonus_payment_orders", "orders"
  add_foreign_key "bonus_payments", "bonuses"
  add_foreign_key "bonus_payments", "pay_periods"
  add_foreign_key "bonus_payments", "ranks", column: "pay_as_rank"
  add_foreign_key "bonus_payments", "users"
  add_foreign_key "bonuses", "bonus_plans"
  add_foreign_key "bonuses", "products"
  add_foreign_key "customer_notes", "users", column: "author_id"
  add_foreign_key "distributions", "pay_periods"
  add_foreign_key "distributions", "users"
  add_foreign_key "invites", "users"
  add_foreign_key "lead_updates", "quotes"
  add_foreign_key "order_totals", "pay_periods"
  add_foreign_key "order_totals", "products"
  add_foreign_key "order_totals", "users"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "quotes"
  add_foreign_key "orders", "users"
  add_foreign_key "product_receipts", "products"
  add_foreign_key "product_receipts", "users"
  add_foreign_key "qualifications", "products"
  add_foreign_key "qualifications", "rank_paths"
  add_foreign_key "qualifications", "ranks"
  add_foreign_key "quote_field_lookups", "quote_fields"
  add_foreign_key "quote_fields", "products"
  add_foreign_key "quotes", "customers"
  add_foreign_key "quotes", "products"
  add_foreign_key "quotes", "users"
  add_foreign_key "rank_achievements", "pay_periods"
  add_foreign_key "rank_achievements", "rank_paths"
  add_foreign_key "rank_achievements", "ranks"
  add_foreign_key "rank_achievements", "users"
  add_foreign_key "user_group_requirements", "products"
  add_foreign_key "user_group_requirements", "user_groups"
  add_foreign_key "user_overrides", "users"
  add_foreign_key "user_user_groups", "user_groups"
  add_foreign_key "user_user_groups", "users"
  add_foreign_key "users", "rank_paths"
  add_foreign_key "users", "ranks", column: "organic_rank"
  add_foreign_key "users", "users", column: "sponsor_id"
end
