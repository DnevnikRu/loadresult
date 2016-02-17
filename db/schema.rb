# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160217135324) do

  create_table "performance_results", force: :cascade do |t|
    t.integer  "result_id"
    t.datetime "timestamp"
    t.string   "label"
    t.integer  "value",      limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "requests_results", force: :cascade do |t|
    t.integer  "result_id"
    t.integer  "timestamp",     limit: 8
    t.string   "label"
    t.integer  "value",         limit: 8
    t.integer  "response_code"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "results", force: :cascade do |t|
    t.string   "version",       null: false
    t.integer  "duration",      null: false
    t.integer  "rps",           null: false
    t.string   "profile",       null: false
    t.datetime "test_run_date", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
