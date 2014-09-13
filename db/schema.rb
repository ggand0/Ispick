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

ActiveRecord::Schema.define(version: 20140912171151) do

  create_table "favored_images", force: true do |t|
    t.text     "title"
    t.text     "caption"
    t.text     "src_url"
    t.integer  "image_board_id"
    t.integer  "image_id"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "page_url"
    t.text     "site_name"
    t.integer  "views"
    t.integer  "favorites"
    t.datetime "posted_at"
  end

  create_table "features", force: true do |t|
    t.text     "face"
    t.text     "categ_imagenet"
    t.integer  "featurable_id"
    t.string   "featurable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_boards", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.text     "title"
    t.text     "caption"
    t.text     "src_url"
    t.boolean  "is_illust"
    t.float    "quality"
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

  add_index "images", ["md5_checksum", "created_at"], name: "index_images_on_md5_checksum_and_created_at", using: :btree
  add_index "images", ["src_url"], name: "index_images_on_src_url", length: {"src_url"=>255}, using: :btree

  create_table "images_tags", force: true do |t|
    t.integer "image_id", null: false
    t.integer "tag_id",   null: false
  end

  add_index "images_tags", ["image_id"], name: "index_images_tags_on_image_id", using: :btree

  create_table "images_target_words", force: true do |t|
    t.integer "image_id",       null: false
    t.integer "target_word_id", null: false
  end

  create_table "keywords", force: true do |t|
    t.boolean  "is_alias"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywords", ["name"], name: "index_keywords_on_name", length: {"name"=>10}, using: :btree

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "name_display"
    t.string   "name_roman"
    t.string   "name_english"
    t.string   "name_type"
    t.integer  "target_word_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["name", "name_english", "name_display"], name: "index_people_on_name_and_name_english_and_name_display", using: :btree
  add_index "people", ["target_word_id"], name: "index_people_on_target_word_id", using: :btree

  create_table "people_keywords", force: true do |t|
    t.integer "keyword_id", null: false
    t.integer "person_id",  null: false
  end

  create_table "people_titles", force: true do |t|
    t.integer "title_id",  null: false
    t.integer "person_id", null: false
  end

  add_index "people_titles", ["person_id", "title_id"], name: "index_people_titles_on_person_id_and_title_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "target_images", force: true do |t|
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
    t.string   "name"
    t.datetime "last_delivered_at"
    t.datetime "newest_scraped_at"
    t.datetime "oldest_scraped_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "crawl_count",       default: 0, null: false
    t.integer  "images_count",      default: 0, null: false
    t.integer  "users_count",       default: 0, null: false
  end

  create_table "target_words_users", force: true do |t|
    t.integer "target_word_id", null: false
    t.integer "user_id",        null: false
  end

  create_table "titles", force: true do |t|
    t.text     "name"
    t.text     "name_roman"
    t.text     "name_english"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "id_anidb"
  end

  add_index "titles", ["name", "name_english"], name: "index_titles_on_name_and_name_english", length: {"name"=>10, "name_english"=>10}, using: :btree

  create_table "users", force: true do |t|
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
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
