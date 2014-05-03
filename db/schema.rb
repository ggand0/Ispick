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

ActiveRecord::Schema.define(version: 20140422033323) do

  create_table "delivered_images", force: true do |t|
    t.integer  "user_id"
    t.integer  "image_id"
    t.integer  "favored_image_id"
    t.integer  "targetable_id"
    t.string   "targetable_type"
    t.boolean  "favored"
    t.boolean  "avoided"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favored_images", force: true do |t|
    t.text     "title"
    t.text     "caption"
    t.text     "src_url"
    t.integer  "user_id"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", force: true do |t|
    t.text     "face"
    t.integer  "featurable_id"
    t.string   "featurable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.text     "title"
    t.text     "caption"
    t.text     "src_url"
    t.boolean  "is_illust"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "md5_checksum"
    t.text     "page_url"
    t.text     "site_name"
    t.string   "module_name"
    t.integer  "views"
    t.integer  "favorites"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images_tags", id: false, force: true do |t|
    t.integer "image_id", null: false
    t.integer "tag_id",   null: false
  end

  create_table "keywords", force: true do |t|
    t.boolean  "is_alias"
    t.text     "word"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "name_display"
    t.string   "name_type"
    t.integer  "target_word_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "target_images", force: true do |t|
    t.text     "title"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.integer  "user_id"
    t.datetime "last_delivered_at"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "target_words", force: true do |t|
    t.string   "word"
    t.integer  "user_id"
    t.datetime "last_delivered_at"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "uid",                    limit: 8
    t.string   "name"
    t.string   "provider"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end
