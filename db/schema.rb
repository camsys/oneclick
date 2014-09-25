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

ActiveRecord::Schema.define(version: 20140925182157) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"

  create_table "accommodations", force: true do |t|
    t.string  "name",                  limit: 64,                 null: false
    t.string  "note"
    t.string  "datatype",              limit: 25,                 null: false
    t.boolean "requires_verification",            default: false, null: false
    t.boolean "active",                           default: true,  null: false
    t.string  "code"
    t.integer "sequence",                         default: 0
    t.boolean "ask_early",                        default: true
    t.string  "logo_url"
  end

  create_table "agencies", force: true do |t|
    t.string  "name",                   limit: 64
    t.string  "address",                limit: 100
    t.string  "city",                   limit: 100
    t.string  "state",                  limit: 64
    t.string  "zip",                    limit: 10
    t.string  "phone",                  limit: 25
    t.string  "email"
    t.string  "url"
    t.integer "parent_id"
    t.string  "internal_contact_name"
    t.string  "internal_contact_title"
    t.string  "internal_contact_phone"
    t.string  "internal_contact_email", limit: 128
    t.boolean "active",                             default: true, null: false
    t.text    "private_comments"
    t.text    "public_comments"
  end

  create_table "agency_user_relationships", force: true do |t|
    t.integer  "agency_id",                          null: false
    t.integer  "user_id",                            null: false
    t.integer  "relationship_status_id", default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator",                            null: false
  end

  create_table "boundaries", force: true do |t|
    t.integer "gid"
    t.string  "agency"
    t.spatial "geom",   limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "characteristics", force: true do |t|
    t.string  "name",                     limit: 64
    t.string  "note",                                                 null: false
    t.string  "datatype",                 limit: 25,                  null: false
    t.boolean "requires_verification",                default: false, null: false
    t.boolean "active",                               default: true,  null: false
    t.string  "code"
    t.string  "characteristic_type",      limit: 128
    t.string  "desc",                                 default: ""
    t.integer "sequence",                             default: 0
    t.boolean "ask_early",                            default: true
    t.string  "logo_url"
    t.boolean "for_service",                          default: true
    t.boolean "for_traveler",                         default: true
    t.integer "linked_characteristic_id"
    t.string  "link_handler"
  end

  create_table "cities", primary_key: "gid", force: true do |t|
    t.string  "geoid", limit: 7
    t.string  "name",  limit: 100
    t.string  "state", limit: 2
    t.spatial "geom",  limit: {:srid=>0, :type=>"multi_polygon"}
  end

  create_table "counties", force: true do |t|
    t.integer "gid"
    t.string  "name"
    t.string  "state"
    t.spatial "geom",  limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "coverage_areas", force: true do |t|
    t.integer "service_id", null: false
    t.boolean "active",     null: false
  end

  create_table "date_options", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "start_date"
    t.string   "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fare_structures", force: true do |t|
    t.integer "service_id",                                                 null: false
    t.string  "note",       limit: 254
    t.integer "fare_type",                                      default: 0
    t.decimal "base",                   precision: 6, scale: 2
    t.decimal "rate",                   precision: 6, scale: 2
    t.text    "desc"
  end

  create_table "geo_coverages", force: true do |t|
    t.string  "value"
    t.string  "coverage_type", limit: 128
    t.string  "polygon"
    t.spatial "geom",          limit: {:srid=>0, :type=>"geometry"}
  end

  add_index "geo_coverages", ["geom"], :name => "index_geo_coverages_on_geom", :spatial => true

  create_table "itineraries", force: true do |t|
    t.integer  "trip_part_id"
    t.integer  "mode_id"
    t.integer  "service_id"
    t.integer  "server_status"
    t.text     "server_message"
    t.integer  "duration"
    t.integer  "walk_time"
    t.integer  "transit_time"
    t.integer  "wait_time"
    t.float    "walk_distance"
    t.integer  "transfers"
    t.integer  "count"
    t.text     "legs"
    t.decimal  "cost",                     precision: 10, scale: 2
    t.boolean  "hidden",                                                            null: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "ride_count"
    t.text     "external_info"
    t.float    "match_score",                                       default: 0.0
    t.boolean  "missing_information",                               default: false
    t.boolean  "accommodation_mismatch",                            default: false
    t.text     "missing_information_text"
    t.boolean  "date_mismatch",                                     default: false
    t.boolean  "time_mismatch",                                     default: false
    t.boolean  "too_late",                                          default: false
    t.string   "missing_accommodations",                            default: ""
    t.text     "cost_comments"
    t.boolean  "selected"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_bookable",                                       default: false, null: false
    t.string   "booking_confirmation"
    t.boolean  "duration_estimated",                                default: false
  end

  create_table "kiosk_locations", force: true do |t|
    t.string   "name"
    t.integer  "address_type"
    t.string   "addr"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "modes", force: true do |t|
    t.string  "name",               limit: 64,                 null: false
    t.boolean "active",                                        null: false
    t.string  "code"
    t.boolean "elig_dependent",                default: false
    t.integer "parent_id"
    t.string  "otp_mode"
    t.integer "results_sort_order"
    t.string  "logo_url"
    t.boolean "visible",                       default: false
  end

  create_table "oneclick_configurations", force: true do |t|
    t.string   "code"
    t.text     "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: true do |t|
    t.integer  "user_id",                                null: false
    t.integer  "creator_id"
    t.string   "name",        limit: 64,                 null: false
    t.integer  "poi_id"
    t.string   "raw_address", limit: 254
    t.string   "address1",    limit: 128
    t.string   "address2",    limit: 128
    t.string   "city",        limit: 128
    t.string   "state",       limit: 64
    t.string   "zip",         limit: 10
    t.float    "lat"
    t.float    "lon"
    t.boolean  "active",                  default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "county",      limit: 128
    t.boolean  "home"
  end

  create_table "poi_types", force: true do |t|
    t.string  "name",   limit: 64, null: false
    t.boolean "active",            null: false
  end

  create_table "pois", force: true do |t|
    t.integer  "poi_type_id",             null: false
    t.string   "name",        limit: 256, null: false
    t.string   "address1",    limit: 128
    t.string   "address2",    limit: 128
    t.string   "city",        limit: 128
    t.string   "state",       limit: 64
    t.string   "zip",         limit: 10
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "county",      limit: 128
  end

  create_table "profile_types", force: true do |t|
    t.string "name",        limit: 64
    t.string "description", limit: 254
  end

  create_table "properties", force: true do |t|
    t.string   "category",   limit: 64
    t.string   "name",       limit: 64
    t.string   "value"
    t.integer  "sort_order"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "providers", force: true do |t|
    t.string  "name",                   limit: 64,                 null: false
    t.string  "external_id",            limit: 25
    t.boolean "active",                             default: true, null: false
    t.string  "email"
    t.string  "address",                limit: 100
    t.string  "city",                   limit: 100
    t.string  "state",                  limit: 64
    t.string  "zip",                    limit: 10
    t.string  "url"
    t.string  "phone",                  limit: 25
    t.string  "internal_contact_name"
    t.string  "internal_contact_title"
    t.string  "internal_contact_phone"
    t.string  "internal_contact_email", limit: 128
    t.string  "old_logo_url"
    t.text    "private_comments"
    t.text    "public_comments"
    t.string  "icon"
    t.string  "logo"
  end

  create_table "ratings", force: true do |t|
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "value",                             null: false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",        default: "pending"
  end

  create_table "relationship_statuses", force: true do |t|
    t.string "name", limit: 64
    t.string "code"
  end

  create_table "reports", force: true do |t|
    t.string   "name",        limit: 64
    t.string   "description", limit: 254
    t.string   "view_name",   limit: 64
    t.string   "class_name",  limit: 64
    t.boolean  "active"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "roles", force: true do |t|
    t.string   "name",          limit: 64
    t.integer  "resource_id"
    t.string   "resource_type", limit: 64
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "schedules", force: true do |t|
    t.integer  "service_id",                   null: false
    t.integer  "day_of_week",                  null: false
    t.boolean  "active",        default: true, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "start_seconds"
    t.integer  "end_seconds"
  end

  create_table "service_accommodations", force: true do |t|
    t.integer "service_id",                            null: false
    t.integer "accommodation_id",                      null: false
    t.boolean "requires_verification", default: false, null: false
    t.boolean "active",                default: true,  null: false
  end

  create_table "service_characteristics", force: true do |t|
    t.integer "service_id",                                       null: false
    t.integer "characteristic_id",                                null: false
    t.string  "value",                 limit: 64,                 null: false
    t.boolean "requires_verification",            default: false, null: false
    t.boolean "active",                           default: true,  null: false
    t.integer "rel_code",                         default: 1,     null: false
    t.integer "group",                            default: 0,     null: false
  end

  create_table "service_coverage_maps", force: true do |t|
    t.integer "service_id"
    t.integer "geo_coverage_id"
    t.string  "rule"
  end

  create_table "service_trip_purpose_maps", force: true do |t|
    t.integer "service_id",                     null: false
    t.integer "trip_purpose_id",                null: false
    t.boolean "active",          default: true, null: false
    t.integer "rel_code"
  end

  create_table "service_types", force: true do |t|
    t.string "name", limit: 64, null: false
    t.string "note"
    t.string "code"
  end

  create_table "services", force: true do |t|
    t.string   "name",                         limit: 64,                  null: false
    t.integer  "provider_id",                                              null: false
    t.integer  "service_type_id",                                          null: false
    t.integer  "advanced_notice_minutes",                  default: 0,     null: false
    t.boolean  "volunteer_drivers_used",                   default: false, null: false
    t.boolean  "accepting_new_clients",                    default: true,  null: false
    t.boolean  "wait_list_in_effect",                      default: false, null: false
    t.boolean  "requires_prior_authorization",             default: false, null: false
    t.boolean  "active",                                   default: true,  null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "email"
    t.string   "external_id",                  limit: 100
    t.string   "phone",                        limit: 25
    t.string   "url"
    t.string   "booking_service_code"
    t.integer  "service_window"
    t.float    "time_factor"
    t.string   "internal_contact_name"
    t.string   "internal_contact_email"
    t.string   "internal_contact_title"
    t.string   "internal_contact_phone"
    t.string   "logo_url"
    t.integer  "endpoint_area_geom_id"
    t.integer  "coverage_area_geom_id"
    t.integer  "residence_area_geom_id"
    t.text     "public_comments"
    t.text     "private_comments"
    t.string   "logo"
  end

  create_table "services_users", id: false, force: true do |t|
    t.integer "user_id",    null: false
    t.integer "service_id", null: false
  end

  add_index "services_users", ["service_id", "user_id"], :name => "index_services_users_on_service_id_and_user_id"

  create_table "sidewalk_obstructions", force: true do |t|
    t.integer  "user_id",                        null: false
    t.float    "lat",                            null: false
    t.float    "lon",                            null: false
    t.string   "comment",                        null: false
    t.datetime "removed_at"
    t.string   "status",     default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", force: true do |t|
    t.string   "key"
    t.text     "interpolations"
    t.boolean  "is_proc",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.text     "value"
    t.boolean  "is_html",        default: false
    t.boolean  "complete",       default: false
    t.boolean  "is_list",        default: false
  end

  create_table "traveler_notes", force: true do |t|
    t.integer "user_id"
    t.integer "agency_id"
    t.text    "note"
  end

  create_table "trip_parts", force: true do |t|
    t.integer  "trip_id"
    t.integer  "from_trip_place_id"
    t.integer  "to_trip_place_id"
    t.integer  "sequence",                           null: false
    t.boolean  "is_depart",          default: false
    t.boolean  "is_return_trip",     default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.date     "scheduled_date"
    t.datetime "scheduled_time"
  end

  add_index "trip_parts", ["trip_id", "sequence"], :name => "index_trip_parts_on_trip_id_and_sequence"

  create_table "trip_places", force: true do |t|
    t.integer  "trip_id"
    t.integer  "sequence",                 null: false
    t.integer  "place_id"
    t.integer  "poi_id"
    t.string   "raw_address"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "address1",     limit: 128
    t.string   "address2",     limit: 128
    t.string   "city",         limit: 128
    t.string   "state",        limit: 64
    t.string   "zip",          limit: 10
    t.string   "county",       limit: 128
    t.string   "result_types"
    t.string   "name",         limit: 256
  end

  create_table "trip_purposes", force: true do |t|
    t.string  "name",       limit: 64,                null: false
    t.string  "note"
    t.boolean "active",                default: true, null: false
    t.integer "sort_order"
    t.string  "code"
  end

  create_table "trip_statuses", force: true do |t|
    t.string  "name",   limit: 64
    t.boolean "active",            null: false
    t.string  "code"
  end

  create_table "trips", force: true do |t|
    t.string   "name",                  limit: 64
    t.integer  "user_id"
    t.integer  "trip_purpose_id"
    t.integer  "creator_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "taken"
    t.date     "scheduled_date"
    t.datetime "scheduled_time"
    t.text     "planned_trip_html"
    t.boolean  "needs_feedback_prompt"
    t.text     "debug_info"
    t.string   "user_agent"
    t.string   "ui_mode"
  end

  create_table "trips_desired_modes", force: true do |t|
    t.integer "trip_id",         null: false
    t.integer "desired_mode_id", null: false
  end

  create_table "user_accommodations", force: true do |t|
    t.integer  "user_profile_id",                             null: false
    t.integer  "accommodation_id",                            null: false
    t.string   "value",            limit: 64,                 null: false
    t.boolean  "verified",                    default: false, null: false
    t.datetime "verified_at"
    t.integer  "verified_by_id"
  end

  create_table "user_characteristics", force: true do |t|
    t.integer  "user_profile_id",                              null: false
    t.integer  "characteristic_id",                            null: false
    t.string   "value",             limit: 64,                 null: false
    t.boolean  "verified",                     default: false, null: false
    t.datetime "verified_at"
    t.integer  "verified_by_id"
  end

  create_table "user_mode_preferences", force: true do |t|
    t.integer  "user_id"
    t.integer  "mode_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profiles", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_relationships", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "delegate_id",            null: false
    t.integer  "relationship_status_id", null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_services", force: true do |t|
    t.integer  "user_profile_id",                                  null: false
    t.integer  "service_id",                                       null: false
    t.string   "external_user_id",                                 null: false
    t.boolean  "disabled",         default: false,                 null: false
    t.string   "customer_id"
    t.datetime "updated_at",       default: '2014-08-26 14:30:52', null: false
    t.datetime "created_at",       default: '2014-08-26 14:30:52', null: false
  end

  create_table "users", force: true do |t|
    t.string   "nickname",                    limit: 64
    t.string   "prefix",                      limit: 4
    t.string   "first_name",                  limit: 64,                 null: false
    t.string   "last_name",                   limit: 64,                 null: false
    t.string   "suffix",                      limit: 4
    t.string   "email",                       limit: 128,                null: false
    t.string   "encrypted_password",          limit: 64,                 null: false
    t.string   "reset_password_token",        limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 16
    t.string   "last_sign_in_ip",             limit: 16
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "agency_id"
    t.string   "preferred_locale",                        default: "en"
    t.string   "authentication_token"
    t.integer  "provider_id"
    t.string   "title",                       limit: 64
    t.string   "phone",                       limit: 25
    t.integer  "walking_speed_id"
    t.integer  "walking_maximum_distance_id"
    t.datetime "deleted_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "value_relationships", force: true do |t|
    t.string   "relationship", limit: 64
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "walking_maximum_distances", force: true do |t|
    t.float    "value",                      null: false
    t.boolean  "is_default", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "walking_speeds", force: true do |t|
    t.string   "code",                       null: false
    t.string   "name",                       null: false
    t.float    "value",                      null: false
    t.boolean  "is_default", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zipcodes", force: true do |t|
    t.integer "gid"
    t.string  "zipcode"
    t.string  "name"
    t.string  "state"
    t.spatial "geom",    limit: {:srid=>0, :type=>"geometry"}
  end

end
