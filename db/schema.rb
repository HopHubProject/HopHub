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

ActiveRecord::Schema[8.1].define(version: 2026_05_19_120000) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.integer "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "contents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "fallback"
    t.string "locale"
    t.string "name"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :string, force: :cascade do |t|
    t.string "admin_email"
    t.string "admin_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "default_country"
    t.text "description"
    t.datetime "end_date"
    t.string "name"
    t.integer "seats_added_total", default: 0, null: false
    t.boolean "shadow_banned", default: false
    t.datetime "updated_at", null: false
  end

  create_table "offers", id: :string, force: :cascade do |t|
    t.datetime "confirmed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "date"
    t.string "direction"
    t.boolean "driver", default: false, null: false
    t.string "email"
    t.string "event_id", null: false
    t.decimal "latitude", precision: 15, scale: 10
    t.string "locale"
    t.string "location"
    t.decimal "longitude", precision: 15, scale: 10
    t.string "name"
    t.text "notes"
    t.string "phone"
    t.integer "seats"
    t.string "token"
    t.string "transport"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_offers_on_event_id"
  end

  create_table "ride_requests", id: :string, force: :cascade do |t|
    t.datetime "confirmed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "direction"
    t.string "email"
    t.datetime "end_date"
    t.string "event_id", null: false
    t.decimal "latitude", precision: 15, scale: 10
    t.string "locale"
    t.string "location"
    t.decimal "longitude", precision: 15, scale: 10
    t.integer "radius"
    t.datetime "start_date"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_ride_requests_on_event_id"
  end

  add_foreign_key "ride_requests", "events"
end
