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

ActiveRecord::Schema.define(:version => 0) do

  create_table "itineraries", :force => true do |t|
    t.integer  "planned_trip_id"
    t.integer  "mode_id"
    t.integer  "server_status"
    t.text     "server_message"
    t.integer  "duration"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "walk_time"
    t.integer  "transit_time"
    t.integer  "wait_time"
    t.float    "walk_distance"
    t.integer  "transfers"
    t.text     "legs"
    t.decimal  "cost",            :precision => 10, :scale => 2
    t.boolean  "hidden",                                         :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "modes", :force => true do |t|
    t.string  "name",   :limit => 64, :null => false
    t.boolean "active",               :null => false
  end

  create_table "places", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "creator_id"
    t.string   "name",        :limit => 64,  :null => false
    t.integer  "poi_id"
    t.string   "raw_address"
    t.string   "address1",    :limit => 128
    t.string   "address2",    :limit => 128
    t.string   "city",        :limit => 128
    t.string   "state",       :limit => 2
    t.string   "zip",         :limit => 10
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "planned_trips", :force => true do |t|
    t.integer  "trip_id",        :null => false
    t.integer  "creator_id"
    t.boolean  "is_depart",      :null => false
    t.datetime "trip_datetime",  :null => false
    t.integer  "trip_status_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "poi_types", :force => true do |t|
    t.string  "name",   :limit => 64, :null => false
    t.boolean "active",               :null => false
  end

  create_table "pois", :force => true do |t|
    t.integer  "poi_type_id",                :null => false
    t.string   "name",        :limit => 64,  :null => false
    t.string   "address1",    :limit => 128
    t.string   "address2",    :limit => 128
    t.string   "city",        :limit => 128
    t.string   "state",       :limit => 2
    t.string   "zip",         :limit => 10
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "profile_types", :force => true do |t|
    t.string "name",        :limit => 64
    t.string "description"
  end

  create_table "relationship_statuses", :force => true do |t|
    t.string "name", :limit => 64
  end

  create_table "reports", :force => true do |t|
    t.string   "name",        :limit => 64
    t.string   "description"
    t.string   "view_name",   :limit => 64
    t.string   "class_name",  :limit => 64
    t.boolean  "active"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",          :limit => 64
    t.integer  "resource_id"
    t.string   "resource_type", :limit => 64
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "trip_places", :force => true do |t|
    t.integer  "trip_id",     :null => false
    t.integer  "sequence",    :null => false
    t.integer  "place_id"
    t.integer  "poi_id"
    t.string   "raw_address"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "trip_statuses", :force => true do |t|
    t.string  "name",   :limit => 64
    t.boolean "active",               :null => false
  end

  create_table "trips", :force => true do |t|
    t.string   "name",       :limit => 64
    t.integer  "user_id"
    t.integer  "creator_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "user_mode_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "mode_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_relationships", :force => true do |t|
    t.integer  "user_id",                :null => false
    t.integer  "delegate_id",            :null => false
    t.integer  "relationship_status_id", :null => false
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "nickname",               :limit => 64
    t.string   "prefix",                 :limit => 4
    t.string   "first_name",             :limit => 64,                 :null => false
    t.string   "last_name",              :limit => 64,                 :null => false
    t.string   "suffix",                 :limit => 4
    t.string   "email",                  :limit => 128,                :null => false
    t.string   "encrypted_password",     :limit => 64,                 :null => false
    t.string   "reset_password_token",   :limit => 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     :limit => 16
    t.string   "last_sign_in_ip",        :limit => 16
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
