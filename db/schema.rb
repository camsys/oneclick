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

ActiveRecord::Schema.define(version: 20161214201941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "accommodations", force: :cascade do |t|
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

  create_table "agencies", force: :cascade do |t|
    t.text    "name"
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
    t.text    "private_comments_old"
    t.text    "public_comments_old"
    t.string  "token"
    t.string  "disabled_comment"
  end

  create_table "agency_user_relationships", force: :cascade do |t|
    t.integer  "agency_id",                          null: false
    t.integer  "user_id",                            null: false
    t.integer  "relationship_status_id", default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator",                            null: false
  end

  create_table "booking_cut_off_times", force: :cascade do |t|
    t.integer  "service_id",                     null: false
    t.integer  "day_of_week",                    null: false
    t.boolean  "active",          default: true, null: false
    t.integer  "cut_off_seconds",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "boundaries", force: :cascade do |t|
    t.integer "gid"
    t.string  "agency"
  end

  create_table "characteristics", force: :cascade do |t|
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

  create_table "comments", force: :cascade do |t|
    t.text     "comment"
    t.string   "locale"
    t.string   "visibility",       default: "public"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counties", force: :cascade do |t|
    t.integer "gid"
    t.string  "name"
    t.string  "state"
  end

  create_table "coverage_areas", force: :cascade do |t|
    t.integer "service_id", null: false
    t.boolean "active",     null: false
  end

  create_table "date_options", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.string   "start_date"
    t.string   "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ecolane_bookings", force: :cascade do |t|
    t.boolean  "assistant"
    t.integer  "children"
    t.integer  "companions"
    t.integer  "other_passengers"
    t.string   "note_to_driver"
    t.string   "booking_status_code"
    t.string   "booking_status_message"
    t.integer  "itinerary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ecolane_profiles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_trip_purpose"
    t.integer  "service_id"
    t.string   "endpoint"
    t.string   "system"
    t.string   "token"
  end

  create_table "fare_structures", force: :cascade do |t|
    t.integer "service_id",                                                 null: false
    t.string  "note",       limit: 254
    t.integer "fare_type",                                      default: 0
    t.decimal "base",                   precision: 6, scale: 2
    t.decimal "rate",                   precision: 6, scale: 2
    t.text    "desc"
  end

  create_table "fare_zones", force: :cascade do |t|
    t.string   "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_id"
  end

  create_table "feedback_issues", force: :cascade do |t|
    t.string "name"
  end

  create_table "feedback_statuses", force: :cascade do |t|
    t.string "name"
  end

  create_table "feedback_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "user_email"
    t.integer  "user_id"
    t.integer  "trip_id"
    t.integer  "feedback_type_id"
    t.integer  "feedback_rating_id"
    t.integer  "feedback_issue_id"
    t.integer  "feedback_status_id"
    t.text     "comment"
    t.float    "average_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flat_fares", force: :cascade do |t|
    t.float    "one_way_rate"
    t.float    "round_trip_rate"
    t.integer  "fare_structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string   "code",                           null: false
    t.integer  "index"
    t.integer  "service_id",                     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "comment"
    t.boolean  "general_public", default: false
  end

  create_table "geo_coverages", force: :cascade do |t|
    t.string "value"
    t.string "coverage_type", limit: 128
    t.string "polygon"
  end

  create_table "itineraries", force: :cascade do |t|
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
    t.decimal  "cost",                       precision: 10, scale: 2
    t.boolean  "hidden",                                                              null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "ride_count"
    t.text     "external_info"
    t.float    "match_score",                                         default: 0.0
    t.boolean  "missing_information",                                 default: false
    t.boolean  "accommodation_mismatch",                              default: false
    t.text     "missing_information_text"
    t.boolean  "date_mismatch",                                       default: false
    t.boolean  "time_mismatch",                                       default: false
    t.boolean  "too_late",                                            default: false
    t.string   "missing_accommodations",                              default: ""
    t.text     "cost_comments"
    t.boolean  "selected"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_bookable",                                         default: false, null: false
    t.string   "booking_confirmation"
    t.boolean  "duration_estimated",                                  default: false
    t.string   "map_image"
    t.boolean  "too_early",                                           default: false
    t.string   "returned_mode_code"
    t.text     "order_xml"
    t.boolean  "assistant"
    t.integer  "companions"
    t.integer  "children"
    t.integer  "other_passengers"
    t.text     "discounts"
    t.datetime "negotiated_pu_time"
    t.datetime "negotiated_do_time"
    t.datetime "negotiated_pu_window_start"
    t.datetime "negotiated_pu_window_end"
  end

  create_table "kiosk_locations", force: :cascade do |t|
    t.string   "name"
    t.integer  "address_type"
    t.string   "addr"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legs", force: :cascade do |t|
    t.integer  "itinerary_id_id"
    t.integer  "leg_sequence"
    t.integer  "service_id_id"
    t.integer  "mode_id_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float    "leg_time"
    t.float    "leg_distance"
    t.decimal  "cost",                            precision: 10
    t.string   "cost_comments"
    t.text     "otp_leg"
    t.string   "returned_mode_id",     limit: 50
    t.boolean  "is_bookable"
    t.string   "booking_confirmation"
    t.boolean  "duration_estimated"
    t.text     "order_xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locales", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.text     "body"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree

  create_table "mileage_fares", force: :cascade do |t|
    t.float    "base_rate"
    t.float    "mileage_rate"
    t.integer  "fare_structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "modes", force: :cascade do |t|
    t.string  "name",                limit: 64,                 null: false
    t.boolean "active",                                         null: false
    t.string  "code"
    t.boolean "elig_dependent",                 default: false
    t.integer "parent_id"
    t.string  "otp_mode"
    t.integer "results_sort_order"
    t.string  "logo_url"
    t.boolean "visible",                        default: false
    t.boolean "selected_by_default",            default: true
  end

  create_table "multi_origin_dest_trips", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.text     "origin_places", null: false
    t.text     "dest_places",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oneclick_configurations", force: :cascade do |t|
    t.string   "code"
    t.text     "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: :cascade do |t|
    t.integer  "user_id",                                    null: false
    t.integer  "creator_id"
    t.string   "name",            limit: 64,                 null: false
    t.integer  "poi_id"
    t.string   "raw_address",     limit: 254
    t.string   "address1",        limit: 128
    t.string   "address2",        limit: 128
    t.string   "city",            limit: 128
    t.string   "state",           limit: 64
    t.string   "zip",             limit: 10
    t.float    "lat"
    t.float    "lon"
    t.boolean  "active",                      default: true
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "county",          limit: 128
    t.boolean  "home"
    t.string   "street_number"
    t.string   "route"
    t.string   "google_place_id"
    t.string   "stop_code"
    t.text     "types"
  end

  create_table "poi_types", force: :cascade do |t|
    t.string  "name",   limit: 64, null: false
    t.boolean "active",            null: false
  end

  create_table "pois", force: :cascade do |t|
    t.integer  "poi_type_id",                                           null: false
    t.string   "name",            limit: 256,                           null: false
    t.string   "address1",        limit: 128
    t.string   "address2",        limit: 128
    t.string   "city",            limit: 128
    t.string   "state",           limit: 64
    t.string   "zip",             limit: 10
    t.decimal  "lat",                         precision: 15, scale: 10
    t.decimal  "lon",                         precision: 15, scale: 10
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "county",          limit: 128
    t.boolean  "old"
    t.string   "street_number"
    t.string   "route"
    t.string   "google_place_id"
    t.text     "types"
    t.string   "stop_code"
  end

  create_table "profile_types", force: :cascade do |t|
    t.string "name",        limit: 64
    t.string "description", limit: 254
  end

  create_table "properties", force: :cascade do |t|
    t.string   "category",   limit: 64
    t.string   "name",       limit: 64
    t.string   "value"
    t.integer  "sort_order"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "providers", force: :cascade do |t|
    t.text    "name",                                              null: false
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
    t.text    "private_comments_old"
    t.text    "public_comments_old"
    t.string  "icon"
    t.string  "logo"
    t.string  "disabled_comment"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "value",                             null: false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",        default: "pending"
  end

  create_table "relationship_statuses", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "code"
  end

  create_table "reporting_filter_fields", force: :cascade do |t|
    t.integer  "reporting_filter_group_id",             null: false
    t.integer  "reporting_filter_type_id",              null: false
    t.integer  "reporting_lookup_table_id"
    t.string   "name",                                  null: false
    t.string   "title"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "sort_order",                default: 1, null: false
    t.string   "value_type"
  end

  create_table "reporting_filter_groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reporting_filter_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reporting_lookup_tables", force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "display_field_name",                null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "id_field_name",      default: "id", null: false
    t.string   "data_access_type"
  end

  create_table "reporting_output_fields", force: :cascade do |t|
    t.integer  "reporting_report_id", null: false
    t.string   "name",                null: false
    t.string   "title"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "formatter"
    t.integer  "numeric_precision"
  end

  create_table "reporting_reports", force: :cascade do |t|
    t.string   "name",                             null: false
    t.string   "description"
    t.string   "data_source",                      null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "is_sys_admin"
    t.boolean  "is_provider_staff"
    t.boolean  "is_agency_admin"
    t.boolean  "is_agent"
    t.string   "primary_key",       default: "id", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string   "name",        limit: 64
    t.string   "description", limit: 254
    t.string   "view_name",   limit: 64
    t.string   "class_name",  limit: 64
    t.boolean  "active"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "exportable",              default: false
  end

  create_table "ridepilot_bookings", force: :cascade do |t|
    t.integer  "leg"
    t.integer  "guests"
    t.integer  "attendants"
    t.integer  "mobility_devices"
    t.integer  "itinerary_id"
    t.string   "trip_purpose_code"
    t.string   "booking_status_code"
    t.string   "booking_status_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "booking_status_name"
  end

  create_table "ridepilot_profiles", force: :cascade do |t|
    t.string   "endpoint"
    t.string   "api_token"
    t.string   "provider_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 64
    t.integer  "resource_id"
    t.string   "resource_type", limit: 64
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "satisfaction_surveys", force: :cascade do |t|
    t.integer  "trip_id",    null: false
    t.boolean  "satisfied",  null: false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reasoning"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "service_id",                   null: false
    t.integer  "day_of_week",                  null: false
    t.boolean  "active",        default: true, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "start_seconds"
    t.integer  "end_seconds"
  end

  create_table "service_accommodations", force: :cascade do |t|
    t.integer "service_id",                            null: false
    t.integer "accommodation_id",                      null: false
    t.boolean "requires_verification", default: false, null: false
    t.boolean "active",                default: true,  null: false
  end

  create_table "service_characteristics", force: :cascade do |t|
    t.integer "service_id",                                       null: false
    t.integer "characteristic_id",                                null: false
    t.string  "value",                 limit: 64,                 null: false
    t.boolean "requires_verification",            default: false, null: false
    t.boolean "active",                           default: true,  null: false
    t.integer "rel_code",                         default: 1,     null: false
    t.integer "group",                            default: 0,     null: false
  end

  create_table "service_coverage_maps", force: :cascade do |t|
    t.integer "service_id"
    t.integer "geo_coverage_id"
    t.string  "rule"
  end

  create_table "service_trip_purpose_maps", force: :cascade do |t|
    t.integer "service_id",                     null: false
    t.integer "trip_purpose_id",                null: false
    t.boolean "active",          default: true, null: false
    t.integer "rel_code"
  end

  create_table "service_types", force: :cascade do |t|
    t.string  "name",   limit: 64,                null: false
    t.string  "note"
    t.string  "code"
    t.boolean "active",            default: true
  end

  create_table "services", force: :cascade do |t|
    t.text     "name",                                                     null: false
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
    t.text     "public_comments_old"
    t.text     "private_comments_old"
    t.string   "logo"
    t.integer  "max_advanced_book_minutes",                default: 0,     null: false
    t.string   "display_color"
    t.integer  "mode_id"
    t.string   "taxi_fare_finder_city",        limit: 64
    t.boolean  "use_gtfs_colors"
    t.string   "disabled_comment"
    t.string   "fare_user"
    t.string   "booking_system_id"
    t.string   "booking_token"
    t.text     "disallowed_purposes"
    t.integer  "booking_profile"
  end

  create_table "services_users", id: false, force: :cascade do |t|
    t.integer "user_id",    null: false
    t.integer "service_id", null: false
  end

  create_table "sidewalk_obstructions", force: :cascade do |t|
    t.integer  "user_id",                        null: false
    t.float    "lat",                            null: false
    t.float    "lon",                            null: false
    t.string   "comment",                        null: false
    t.datetime "removed_at"
    t.string   "status",     default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "code",       null: false
    t.integer  "index"
    t.integer  "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translation_keys", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", force: :cascade do |t|
    t.string   "key"
    t.text     "interpolations"
    t.boolean  "is_proc",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.text     "value"
    t.boolean  "is_html",            default: false
    t.boolean  "complete",           default: false
    t.boolean  "is_list",            default: false
    t.integer  "locale_id"
    t.integer  "translation_key_id"
  end

  create_table "trapeze_bookings", force: :cascade do |t|
    t.string   "passenger1_type"
    t.string   "passenger1_space_type"
    t.string   "passenger2_type"
    t.string   "passenger2_space_type"
    t.string   "passenger3_type"
    t.string   "passenger3_space_type"
    t.integer  "itinerary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fare1_type_id"
    t.string   "fare2_type_id"
    t.string   "fare3_type_id"
  end

  create_table "trapeze_profiles", force: :cascade do |t|
    t.string   "endpoint"
    t.string   "username"
    t.string   "password"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
    t.integer  "para_service_id"
    t.integer  "booking_offset_minutes", default: 0, null: false
  end

  create_table "traveler_notes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "agency_id"
    t.text    "note"
  end

  create_table "trip_parts", force: :cascade do |t|
    t.integer  "trip_id"
    t.integer  "from_trip_place_id"
    t.integer  "to_trip_place_id"
    t.integer  "sequence",                                  null: false
    t.boolean  "is_depart",                 default: false
    t.boolean  "is_return_trip",            default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.date     "scheduled_date"
    t.datetime "scheduled_time"
    t.boolean  "assistant"
    t.integer  "companions"
    t.integer  "children"
    t.integer  "other_passengers"
    t.text     "note_to_driver"
    t.integer  "booking_trip_purpose_id"
    t.string   "booking_trip_purpose_desc"
    t.string   "preferred_routes"
    t.string   "banned_routes"
    t.text     "otp_response"
  end

  create_table "trip_places", force: :cascade do |t|
    t.integer  "trip_id"
    t.integer  "sequence",                                                     null: false
    t.integer  "place_id"
    t.integer  "poi_id"
    t.string   "raw_address"
    t.decimal  "lat",                                precision: 15, scale: 10
    t.decimal  "lon",                                precision: 15, scale: 10
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "address1",               limit: 128
    t.string   "address2",               limit: 128
    t.string   "city",                   limit: 128
    t.string   "state",                  limit: 64
    t.string   "zip",                    limit: 10
    t.string   "county",                 limit: 128
    t.string   "result_types"
    t.string   "name",                   limit: 256
    t.string   "street_number"
    t.string   "route"
    t.string   "google_place_id"
    t.string   "stop_code"
    t.text     "types"
    t.text     "address_components_raw"
  end

  create_table "trip_purposes", force: :cascade do |t|
    t.string  "name",       limit: 64,                null: false
    t.string  "note"
    t.boolean "active",                default: true, null: false
    t.integer "sort_order"
    t.string  "code"
  end

  create_table "trip_statuses", force: :cascade do |t|
    t.string  "name",   limit: 64
    t.boolean "active",            null: false
    t.string  "code"
  end

  create_table "trips", force: :cascade do |t|
    t.string   "name",                      limit: 64
    t.integer  "user_id"
    t.integer  "trip_purpose_id"
    t.integer  "creator_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "taken"
    t.date     "scheduled_date"
    t.datetime "scheduled_time"
    t.text     "planned_trip_html"
    t.boolean  "needs_feedback_prompt"
    t.text     "debug_info"
    t.string   "user_agent"
    t.string   "ui_mode"
    t.integer  "multi_origin_dest_trip_id"
    t.integer  "agency_id"
    t.integer  "outbound_provider_id"
    t.integer  "return_provider_id"
    t.string   "kiosk_code"
    t.string   "token"
    t.boolean  "is_planned",                           default: false
    t.string   "agency_token"
    t.string   "trip_purpose_raw"
    t.string   "optimize",                             default: "TIME"
    t.float    "max_walk_miles"
    t.integer  "max_walk_seconds"
    t.float    "walk_mph",                             default: 3.0
    t.integer  "num_itineraries",                      default: 3
    t.float    "max_bike_miles",                       default: 5.0
    t.integer  "min_transfer_time"
    t.string   "desired_modes_raw"
    t.string   "source_tag"
    t.integer  "max_transfer_time"
  end

  create_table "trips_desired_modes", force: :cascade do |t|
    t.integer "trip_id",         null: false
    t.integer "desired_mode_id", null: false
  end

  create_table "user_accommodations", force: :cascade do |t|
    t.integer  "user_profile_id",                             null: false
    t.integer  "accommodation_id",                            null: false
    t.string   "value",            limit: 64,                 null: false
    t.boolean  "verified",                    default: false, null: false
    t.datetime "verified_at"
    t.integer  "verified_by_id"
  end

  create_table "user_characteristics", force: :cascade do |t|
    t.integer  "user_profile_id",                              null: false
    t.integer  "characteristic_id",                            null: false
    t.string   "value",             limit: 64,                 null: false
    t.boolean  "verified",                     default: false, null: false
    t.datetime "verified_at"
    t.integer  "verified_by_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "message_id"
    t.boolean  "read",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_displayed_at"
    t.datetime "read_at"
  end

  create_table "user_mode_preferences", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mode_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_relationships", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "delegate_id",            null: false
    t.integer  "relationship_status_id", null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_services", force: :cascade do |t|
    t.integer  "user_profile_id",                                         null: false
    t.integer  "service_id",                                              null: false
    t.string   "external_user_id",                                        null: false
    t.boolean  "disabled",                default: false,                 null: false
    t.string   "customer_id"
    t.datetime "updated_at",              default: '2014-08-26 14:30:52', null: false
    t.datetime "created_at",              default: '2014-08-26 14:30:52', null: false
    t.string   "external_user_password"
    t.string   "encrypted_user_password"
  end

  create_table "users", force: :cascade do |t|
    t.string   "nickname",                    limit: 64
    t.string   "prefix",                      limit: 4
    t.string   "first_name",                  limit: 64,                  null: false
    t.string   "last_name",                   limit: 64,                  null: false
    t.string   "suffix",                      limit: 4
    t.string   "email",                       limit: 128,                 null: false
    t.string   "encrypted_password",          limit: 64,                  null: false
    t.string   "reset_password_token",        limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 16
    t.string   "last_sign_in_ip",             limit: 16
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "agency_id"
    t.string   "preferred_locale",                        default: "en"
    t.string   "authentication_token"
    t.integer  "provider_id"
    t.string   "title",                       limit: 64
    t.string   "phone",                       limit: 25
    t.integer  "walking_speed_id"
    t.integer  "walking_maximum_distance_id"
    t.datetime "deleted_at"
    t.integer  "maximum_wait_time"
    t.string   "disabled_comment"
    t.boolean  "api_guest",                               default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "value_relationships", force: :cascade do |t|
    t.string   "relationship", limit: 64
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "walking_maximum_distances", force: :cascade do |t|
    t.float    "value",                      null: false
    t.boolean  "is_default", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "walking_speeds", force: :cascade do |t|
    t.string   "code",                       null: false
    t.string   "name",                       null: false
    t.float    "value",                      null: false
    t.boolean  "is_default", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zipcodes", force: :cascade do |t|
    t.integer "gid"
    t.string  "zipcode"
    t.string  "name"
    t.string  "state"
  end

  create_table "zone_fares", force: :cascade do |t|
    t.integer  "from_zone_id"
    t.integer  "to_zone_id"
    t.integer  "fare_structure_id"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
