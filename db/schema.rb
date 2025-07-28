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

ActiveRecord::Schema[7.2].define(version: 2025_07_28_022854) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "class_schedule_id", null: false
    t.string "booking_type"
    t.string "status"
    t.datetime "booked_at"
    t.datetime "cancelled_at"
    t.string "payment_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_schedule_id"], name: "index_bookings_on_class_schedule_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "class_schedules", force: :cascade do |t|
    t.bigint "dance_class_id", null: false
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.boolean "recurring"
    t.text "recurrence_pattern"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_class_id"], name: "index_class_schedules_on_dance_class_id"
  end

  create_table "dance_classes", force: :cascade do |t|
    t.string "name"
    t.bigint "dance_style_id", null: false
    t.bigint "dance_level_id", null: false
    t.bigint "instructor_id", null: false
    t.bigint "location_id", null: false
    t.integer "duration_minutes"
    t.integer "max_capacity"
    t.decimal "price"
    t.text "description"
    t.string "class_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_level_id"], name: "index_dance_classes_on_dance_level_id"
    t.index ["dance_style_id"], name: "index_dance_classes_on_dance_style_id"
    t.index ["instructor_id"], name: "index_dance_classes_on_instructor_id"
    t.index ["location_id"], name: "index_dance_classes_on_location_id"
  end

  create_table "dance_levels", force: :cascade do |t|
    t.string "name"
    t.integer "level_number"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level_number"], name: "index_dance_levels_on_level_number", unique: true
    t.index ["name"], name: "index_dance_levels_on_name", unique: true
  end

  create_table "dance_styles", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "registration_date"
    t.string "payment_status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "event_type"
    t.bigint "location_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.date "registration_deadline"
    t.decimal "price"
    t.integer "max_participants"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_events_on_location_id"
  end

  create_table "figures", force: :cascade do |t|
    t.string "figure_number"
    t.string "name"
    t.bigint "dance_style_id", null: false
    t.bigint "dance_level_id", null: false
    t.integer "measures"
    t.text "components"
    t.boolean "is_core"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_level_id"], name: "index_figures_on_dance_level_id"
    t.index ["dance_style_id"], name: "index_figures_on_dance_style_id"
  end

  create_table "instructor_availabilities", force: :cascade do |t|
    t.bigint "instructor_id", null: false
    t.bigint "location_id", null: false
    t.integer "day_of_week"
    t.time "start_time"
    t.time "end_time"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id"], name: "index_instructor_availabilities_on_instructor_id"
    t.index ["location_id"], name: "index_instructor_availabilities_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "phone"
    t.integer "capacity"
    t.text "operating_hours"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount"
    t.string "payment_method"
    t.string "transaction_id"
    t.string "status"
    t.datetime "payment_date"
    t.string "invoice_number"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "private_lessons", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "instructor_id", null: false
    t.bigint "dance_style_id", null: false
    t.bigint "dance_level_id", null: false
    t.bigint "location_id", null: false
    t.datetime "scheduled_at"
    t.integer "duration_minutes"
    t.decimal "price"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_level_id"], name: "index_private_lessons_on_dance_level_id"
    t.index ["dance_style_id"], name: "index_private_lessons_on_dance_style_id"
    t.index ["instructor_id"], name: "index_private_lessons_on_instructor_id"
    t.index ["location_id"], name: "index_private_lessons_on_location_id"
    t.index ["student_id"], name: "index_private_lessons_on_student_id"
  end

  create_table "student_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "figure_id", null: false
    t.boolean "movement_passed"
    t.boolean "timing_passed"
    t.boolean "partnering_passed"
    t.datetime "completed_at"
    t.bigint "instructor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["figure_id"], name: "index_student_progresses_on_figure_id"
    t.index ["instructor_id"], name: "index_student_progresses_on_instructor_id"
    t.index ["user_id"], name: "index_student_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "role"
    t.string "membership_type"
    t.decimal "membership_discount"
    t.boolean "waiver_signed"
    t.datetime "waiver_signed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "waitlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "class_schedule_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_schedule_id"], name: "index_waitlists_on_class_schedule_id"
    t.index ["user_id"], name: "index_waitlists_on_user_id"
  end

  add_foreign_key "bookings", "class_schedules"
  add_foreign_key "bookings", "users"
  add_foreign_key "class_schedules", "dance_classes"
  add_foreign_key "dance_classes", "dance_levels"
  add_foreign_key "dance_classes", "dance_styles"
  add_foreign_key "dance_classes", "locations"
  add_foreign_key "dance_classes", "users", column: "instructor_id"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "users"
  add_foreign_key "events", "locations"
  add_foreign_key "figures", "dance_levels"
  add_foreign_key "figures", "dance_styles"
  add_foreign_key "instructor_availabilities", "locations"
  add_foreign_key "instructor_availabilities", "users", column: "instructor_id"
  add_foreign_key "payments", "users"
  add_foreign_key "private_lessons", "dance_levels"
  add_foreign_key "private_lessons", "dance_styles"
  add_foreign_key "private_lessons", "locations"
  add_foreign_key "private_lessons", "users", column: "instructor_id"
  add_foreign_key "private_lessons", "users", column: "student_id"
  add_foreign_key "student_progresses", "figures"
  add_foreign_key "student_progresses", "users"
  add_foreign_key "student_progresses", "users", column: "instructor_id"
  add_foreign_key "waitlists", "class_schedules"
  add_foreign_key "waitlists", "users"
end
