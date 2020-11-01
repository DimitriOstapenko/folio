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

ActiveRecord::Schema.define(version: 2020_10_31_194957) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.float "cash"
    t.integer "currency"
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
    t.float "cashdiv"
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

  add_foreign_key "portfolio_histories", "portfolios"
  add_foreign_key "portfolio_histories", "users"
  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "portfolios"
  add_foreign_key "transactions", "positions"
end
