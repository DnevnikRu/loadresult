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

ActiveRecord::Schema.define(version: 20160520105912) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calculated_performance_results", force: :cascade do |t|
    t.integer "result_id", null: false
    t.string  "label"
    t.float   "mean"
    t.float   "max"
    t.float   "min"
  end

  create_table "calculated_requests_results", force: :cascade do |t|
    t.integer "result_id",         null: false
    t.string  "label"
    t.float   "mean"
    t.float   "median"
    t.float   "ninety_percentile"
    t.float   "max"
    t.float   "min"
    t.float   "throughput"
    t.float   "failed_results"
  end

  create_table "performance_groups", force: :cascade do |t|
    t.string "name"
    t.string "units"
    t.float  "trend_limit"
  end

  create_table "performance_labels", force: :cascade do |t|
    t.integer "performance_group_id"
    t.string  "label"
  end

  create_table "performance_results", force: :cascade do |t|
    t.integer  "result_id"
    t.string   "label"
    t.integer  "value",      limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "timestamp",  limit: 8
  end

  create_table "projects", force: :cascade do |t|
    t.string "project_name", null: false
  end

  create_table "requests_results", force: :cascade do |t|
    t.integer  "result_id"
    t.string   "label"
    t.integer  "value",         limit: 8
    t.string   "response_code"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "timestamp",     limit: 8
  end

  create_table "results", force: :cascade do |t|
    t.string   "version",              null: false
    t.integer  "duration",             null: false
    t.string   "rps",                  null: false
    t.string   "profile",              null: false
    t.datetime "test_run_date",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "time_cutting_percent"
    t.string   "requests_data"
    t.string   "performance_data"
    t.integer  "project_id"
    t.integer  "smoothing_percent"
    t.datetime "release_date"
    t.string   "comment"
    t.string   "data_version"
  end

end
