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

ActiveRecord::Schema[7.1].define(version: 2024_11_21_020923) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.date "date_first_met"
    t.string "current_employer"
    t.string "partner"
    t.date "most_recent_contact_date"
    t.integer "communication_frequency"
    t.string "industry"
    t.string "role"
    t.string "user_id"
    t.string "integer"
    t.string "introduced_by_id"
    t.string "how_met"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "event_type"
    t.date "event_date"
    t.string "event_location"
    t.integer "contact_id"
    t.integer "user_id"
    t.string "intention"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interactions", force: :cascade do |t|
    t.integer "contact_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
