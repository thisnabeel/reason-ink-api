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

ActiveRecord::Schema[8.1].define(version: 2026_01_14_001735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "abstractions", force: :cascade do |t|
    t.integer "abstractable_id"
    t.string "abstractable_type"
    t.text "article"
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "last_edited_by"
    t.integer "position"
    t.string "preview"
    t.string "source_url"
    t.datetime "updated_at", null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.text "body"
    t.integer "chapter_id"
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "title"
    t.datetime "updated_at", null: false
    t.text "youtube_url"
    t.index ["chapter_id"], name: "index_chapters_on_chapter_id"
  end

  create_table "concept_experiments", force: :cascade do |t|
    t.bigint "concept_id", null: false
    t.datetime "created_at", null: false
    t.bigint "experiment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["concept_id"], name: "index_concept_experiments_on_concept_id"
    t.index ["experiment_id"], name: "index_concept_experiments_on_experiment_id"
  end

  create_table "concepts", force: :cascade do |t|
    t.string "avatar_url"
    t.integer "concept_id"
    t.string "concept_type"
    t.datetime "created_at", null: false
    t.integer "end_year"
    t.integer "start_year"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["concept_id"], name: "index_concepts_on_concept_id"
  end

  create_table "examples", force: :cascade do |t|
    t.text "body"
    t.bigint "concept_id", null: false
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["concept_id"], name: "index_examples_on_concept_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "phrases", force: :cascade do |t|
    t.text "body"
    t.bigint "concept_id", null: false
    t.datetime "created_at", null: false
    t.text "explanation"
    t.datetime "updated_at", null: false
    t.index ["concept_id"], name: "index_phrases_on_concept_id"
  end

  create_table "quiz_choices", force: :cascade do |t|
    t.text "body"
    t.boolean "correct", default: false
    t.datetime "created_at", null: false
    t.integer "position"
    t.bigint "quiz_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_choices_on_quiz_id"
  end

  create_table "quiz_set_concepts", force: :cascade do |t|
    t.bigint "concept_id", null: false
    t.datetime "created_at", null: false
    t.bigint "quiz_set_id", null: false
    t.datetime "updated_at", null: false
    t.index ["concept_id"], name: "index_quiz_set_concepts_on_concept_id"
    t.index ["quiz_set_id"], name: "index_quiz_set_concepts_on_quiz_set_id"
  end

  create_table "quiz_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "pop_quizable"
    t.integer "position"
    t.integer "quiz_setable_id"
    t.string "quiz_setable_type"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "quizzes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "jeopardy", default: true
    t.integer "position"
    t.text "question"
    t.integer "quiz_set_id"
    t.integer "quizable_id"
    t.string "quizable_type"
    t.datetime "updated_at", null: false
  end

  create_table "scripts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "position"
    t.integer "scriptable_id", null: false
    t.string "scriptable_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_scripts_on_position"
    t.index ["scriptable_type", "scriptable_id"], name: "index_scripts_on_scriptable_type_and_scriptable_id"
  end

  add_foreign_key "concept_experiments", "concepts"
  add_foreign_key "concept_experiments", "experiments"
  add_foreign_key "examples", "concepts"
  add_foreign_key "phrases", "concepts"
  add_foreign_key "quiz_choices", "quizzes"
  add_foreign_key "quiz_set_concepts", "concepts"
  add_foreign_key "quiz_set_concepts", "quiz_sets"
end
