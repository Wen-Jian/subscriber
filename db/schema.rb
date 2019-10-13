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

ActiveRecord::Schema.define(version: 2019_06_09_085345) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fetch_settings", force: :cascade do |t|
    t.string "destination"
    t.boolean "revoke", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notify_price"
    t.date "start_date"
    t.date "end_date"
    t.integer "flight_type"
    t.string "depart", limit: 255
    t.integer "ticket_type"
  end

  create_table "flight_tickets", force: :cascade do |t|
    t.string "flight_company"
    t.integer "price"
    t.string "destination"
    t.date "flight_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "flight_type"
    t.string "depart", limit: 255
    t.string "url"
  end

end
