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

ActiveRecord::Schema[7.1].define(version: 2024_02_13_101545) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "altcha_solutions", force: :cascade do |t|
    t.string "algorithm"
    t.string "challenge"
    t.string "salt"
    t.string "signature"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["algorithm", "challenge", "salt", "signature", "number"], name: "idx_on_algorithm_challenge_salt_signature_number_7fac118f99", unique: true
  end

  create_table "contents", force: :cascade do |t|
    t.string "name"
    t.string "locale"
    t.boolean "fallback"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", id: :string, force: :cascade do |t|
    t.string "event_id", null: false
    t.string "transport"
    t.string "entry_type"
    t.string "direction"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "date"
    t.decimal "latitude", precision: 15, scale: 10
    t.decimal "longitude", precision: 15, scale: 10
    t.string "location"
    t.integer "seats"
    t.text "notes"
    t.string "token"
    t.datetime "confirmed_at"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_entries_on_event_id"
  end

  create_table "events", id: :string, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "end_date"
    t.string "admin_email"
    t.string "admin_token"
    t.boolean "shadow_banned", default: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "entries", "events"
end
