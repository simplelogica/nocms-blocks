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

ActiveRecord::Schema.define(version: 20150904125311) do

  create_table "no_cms_blocks_block_slots", force: :cascade do |t|
    t.integer  "container_id",   limit: 4
    t.string   "container_type", limit: 255
    t.integer  "block_id",       limit: 4
    t.integer  "position",       limit: 4,   default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "parent_id",      limit: 4
    t.integer  "lft",            limit: 4
    t.integer  "rgt",            limit: 4
    t.integer  "depth",          limit: 4
    t.string   "bone",           limit: 255
  end

  add_index "no_cms_blocks_block_slots", ["block_id"], name: "index_no_cms_blocks_block_slots_on_block_id", using: :btree
  add_index "no_cms_blocks_block_slots", ["container_type", "container_id"], name: "index_no_cms_blocks_block_slots_on_container_type_and_id", using: :btree
  add_index "no_cms_blocks_block_slots", ["parent_id"], name: "index_no_cms_blocks_block_slots_on_parent_id", using: :btree

  create_table "no_cms_blocks_block_translations", force: :cascade do |t|
    t.integer "no_cms_blocks_block_id", limit: 4
    t.string  "locale",                 limit: 255
    t.text    "fields_info",            limit: 4294967295
    t.boolean "draft"
  end

  add_index "no_cms_blocks_block_translations", ["no_cms_blocks_block_id"], name: "no_cms_blocks_blocks_translations_block_id", using: :btree

  create_table "no_cms_blocks_blocks", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",   limit: 4
    t.integer  "lft",         limit: 4
    t.integer  "rgt",         limit: 4
    t.integer  "depth",       limit: 4
    t.integer  "position",    limit: 4
    t.text     "fields_info", limit: 4294967295
    t.string   "layout",      limit: 255
    t.string   "bone",        limit: 255
  end

  add_index "no_cms_blocks_blocks", ["parent_id"], name: "fk_rails_edaaea4d66", using: :btree

  create_table "slotted_pages", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "skeleton",   limit: 255
  end

  create_table "test_images", force: :cascade do |t|
    t.string   "logo",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "no_cms_blocks_block_slots", "no_cms_blocks_block_slots", column: "parent_id"
  add_foreign_key "no_cms_blocks_blocks", "no_cms_blocks_blocks", column: "parent_id"
end
