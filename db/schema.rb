# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_19_003346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "charts", force: :cascade do |t|
    t.string "symbol"
    t.string "exch"
    t.date "date"
    t.float "price"
    t.integer "volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol", "date"], name: "index_charts_on_symbol_and_date", unique: true
  end

  create_table "portfolio_histories", force: :cascade do |t|
    t.float "acb"
    t.float "cash"
    t.float "curval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "portfolio_id"
    t.float "fx_rate", default: 1.0
    t.bigint "user_id"
    t.index ["portfolio_id"], name: "index_portfolio_histories_on_portfolio_id"
    t.index ["user_id"], name: "index_portfolio_histories_on_user_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "currency"
    t.boolean "cashonly", default: false
    t.boolean "taxable", default: false
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "symbol"
    t.float "qty"
    t.string "exch"
    t.integer "currency"
    t.float "acb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "portfolio_id"
    t.float "avg_price"
    t.string "note"
    t.float "cash"
    t.float "fees"
    t.float "gain"
    t.integer "pos_type"
    t.index ["portfolio_id"], name: "index_positions_on_portfolio_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "symbol"
    t.string "exchange"
    t.string "name"
    t.float "latest_price"
    t.float "prev_close"
    t.float "volume"
    t.float "prev_volume"
    t.datetime "latest_update"
    t.float "week52high"
    t.float "week52low"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "ytd_change"
    t.float "change"
    t.float "change_percent"
    t.string "change_percent_s"
    t.string "exch"
    t.float "high"
    t.float "low"
    t.float "market_cap"
    t.float "pe_ratio"
  end

  create_table "transactions", force: :cascade do |t|
    t.float "qty"
    t.bigint "position_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.integer "tr_type"
    t.float "fees", default: 0.0
    t.float "acb"
    t.float "gain", default: 0.0
    t.float "ttl_qty", default: 0.0
    t.float "cash"
    t.string "note"
    t.datetime "date"
    t.float "ttl_cash"
    t.float "ttl_acb"
    t.boolean "cashdep", default: false
    t.boolean "drip", default: false
    t.index ["position_id"], name: "index_transactions_on_position_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "portfolio_histories", "portfolios"
  add_foreign_key "portfolio_histories", "users"
  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "portfolios"
  add_foreign_key "transactions", "positions"
end
