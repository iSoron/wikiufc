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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150906014206) do

  create_table "attachments", :force => true do |t|
    t.string   "file_name",                       :null => false
    t.string   "content_type"
    t.datetime "last_modified"
    t.text     "description"
    t.integer  "size"
    t.integer  "course_id"
    t.datetime "deleted_at"
    t.string   "path"
    t.boolean  "front_page",    :default => true, :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "short_name",                       :null => false
    t.string   "full_name",                        :null => false
    t.text     "description"
    t.string   "code",        :default => "CK000", :null => false
    t.integer  "grade",       :default => 1,       :null => false
    t.datetime "deleted_at"
    t.string   "period",                           :null => false
    t.boolean  "hidden",      :default => false,   :null => false
  end

  add_index "courses", ["short_name"], :name => "index_courses_on_short_name"

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "course_id"
  end

  create_table "event_versions", :force => true do |t|
    t.integer  "event_id"
    t.integer  "version"
    t.string   "title"
    t.date     "date"
    t.datetime "time"
    t.integer  "created_by"
    t.integer  "course_id",   :default => 0
    t.text     "description"
    t.datetime "deleted_at"
  end

  create_table "events", :force => true do |t|
    t.string   "title",                      :null => false
    t.date     "date"
    t.datetime "time",                       :null => false
    t.integer  "created_by",                 :null => false
    t.integer  "course_id",   :default => 0, :null => false
    t.text     "description"
    t.datetime "deleted_at"
    t.integer  "version",     :default => 1, :null => false
  end

  create_table "log_entries", :force => true do |t|
    t.datetime "created_at"
    t.integer  "course_id",  :null => false
    t.integer  "user_id",    :null => false
    t.integer  "version"
    t.integer  "target_id"
    t.string   "type"
    t.datetime "deleted_at"
  end

  create_table "message_versions", :force => true do |t|
    t.integer  "message_id"
    t.integer  "version"
    t.string   "title"
    t.text     "body"
    t.datetime "timestamp"
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.datetime "deleted_at"
    t.string   "versioned_type"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "title"
    t.text     "body",                       :null => false
    t.datetime "timestamp",                  :null => false
    t.integer  "receiver_id"
    t.integer  "sender_id",                  :null => false
    t.string   "type"
    t.datetime "deleted_at"
    t.integer  "version",     :default => 1, :null => false
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "login",                                 :null => false
    t.string   "hashed_password",                       :null => false
    t.string   "email",                                 :null => false
    t.string   "salt",                                  :null => false
    t.datetime "created_at"
    t.string   "name",               :default => "",    :null => false
    t.integer  "pref_color",         :default => 0,     :null => false
    t.string   "display_name",                          :null => false
    t.text     "description"
    t.datetime "last_seen",                             :null => false
    t.string   "login_key"
    t.boolean  "admin",              :default => false, :null => false
    t.string   "secret",                                :null => false
    t.datetime "deleted_at"
    t.string   "password_reset_key"
  end

  create_table "wiki_page_versions", :force => true do |t|
    t.integer  "wiki_page_id", :null => false
    t.integer  "version",      :null => false
    t.integer  "course_id",    :null => false
    t.integer  "user_id",      :null => false
    t.string   "description",  :null => false
    t.string   "title",        :null => false
    t.text     "content",      :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "wiki_pages", :force => true do |t|
    t.integer  "course_id",                         :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "version",                           :null => false
    t.string   "description",                       :null => false
    t.string   "title",                             :null => false
    t.text     "content",                           :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "position",                          :null => false
    t.datetime "deleted_at"
    t.string   "canonical_title",                   :null => false
    t.boolean  "front_page",      :default => true, :null => false
  end

end
