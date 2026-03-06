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

ActiveRecord::Schema[8.0].define(version: 2026_03_05_080000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "boards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["updated_at", "name"], name: "index_boards_on_updated_at_and_name"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "board_id", null: false
    t.index ["board_id", "position"], name: "index_lists_on_board_id_and_position"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "due_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "list_id", null: false
    t.integer "position", default: 1, null: false
    t.datetime "completed_at"
    t.index ["completed_at"], name: "index_tasks_on_completed_at"
    t.index ["due_at"], name: "index_tasks_on_due_at"
    t.index ["list_id", "position"], name: "index_tasks_on_list_id_and_position"
  end

  add_foreign_key "lists", "boards"
  add_foreign_key "tasks", "lists"
end
