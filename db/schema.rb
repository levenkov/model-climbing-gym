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

ActiveRecord::Schema[8.0].define(version: 2026_03_18_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "financial_transaction_type", ["income", "payment"]
  create_enum "schedule_type", ["flexible", "fixed"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.string "record_id", null: false
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "financial_transactions", force: :cascade do |t|
    t.enum "transaction_type", null: false, enum_type: "financial_transaction_type"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category"
    t.string "description"
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_financial_transactions_on_category"
    t.index ["date"], name: "index_financial_transactions_on_date"
    t.index ["transaction_type"], name: "index_financial_transactions_on_transaction_type"
  end

  create_table "gym_states", force: :cascade do |t|
    t.decimal "balance", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "current_visitors", default: 0, null: false
    t.boolean "open", default: false, null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recorded_at"], name: "index_gym_states_on_recorded_at"
  end

  create_table "user_oauths", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_user_oauths_on_provider_and_uid", unique: true
    t.index ["user_id", "provider"], name: "index_user_oauths_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_oauths_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "disabled", default: false, null: false
    t.string "role", default: "regular", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visitor_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "visits_per_week", precision: 3, scale: 1, null: false
    t.enum "schedule_type", null: false, enum_type: "schedule_type"
    t.boolean "has_own_shoes", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_visitor_profiles_on_user_id", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "checked_in_at", null: false
    t.datetime "checked_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checked_in_at"], name: "index_visits_on_checked_in_at"
    t.index ["checked_out_at"], name: "index_visits_on_checked_out_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "user_oauths", "users"
  add_foreign_key "visitor_profiles", "users"
  add_foreign_key "visits", "users"
end
