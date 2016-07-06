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

ActiveRecord::Schema.define(version: 20160706163345) do

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id",     limit: 4,   null: false
    t.string   "text",        limit: 255, null: false
    t.integer  "entity_id",   limit: 4,   null: false
    t.string   "entity_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["entity_id"], name: "index_activities_on_entity_id", using: :btree
  add_index "activities", ["entity_type"], name: "index_activities_on_entity_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.string  "type",        limit: 255
    t.integer "resident_id", limit: 4
    t.string  "name",        limit: 255
    t.text    "description", limit: 65535
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.integer  "attachable_id",     limit: 4,   null: false
    t.string   "attachable_type",   limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
  end

  add_index "attachments", ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id", using: :btree

  create_table "buildings", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",     limit: 4,                     null: false
    t.string   "title",       limit: 255,                   null: false
    t.text     "text",        limit: 65535,                 null: false
    t.boolean  "read",                      default: false
    t.integer  "entity_id",   limit: 4,                     null: false
    t.string   "entity_type", limit: 255,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["entity_id"], name: "index_comments_on_entity_id", using: :btree
  add_index "comments", ["entity_type"], name: "index_comments_on_entity_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "continents", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.integer  "continent_id", limit: 4,   null: false
    t.string   "name",         limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["continent_id"], name: "index_countries_on_continent_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incomes", force: :cascade do |t|
    t.integer  "invoice_id",     limit: 4,                   null: false
    t.integer  "value_in_cents", limit: 4,   default: 0,     null: false
    t.string   "payment",        limit: 255,                 null: false
    t.date     "received",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_currency", limit: 255, default: "CHF", null: false
  end

  add_index "incomes", ["invoice_id"], name: "index_incomes_on_invoice_id", using: :btree

  create_table "institutes", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "parent_id",      limit: 4
    t.integer  "reservation_id", limit: 4,   null: false
    t.integer  "closed",         limit: 1
    t.date     "interval_start"
    t.date     "interval_end"
    t.string   "type",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoices", ["parent_id"], name: "index_invoices_on_parent_id", using: :btree
  add_index "invoices", ["reservation_id"], name: "index_invoices_on_reservation_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "invoice_id",     limit: 4,                   null: false
    t.string   "name",           limit: 255,                 null: false
    t.integer  "value_in_cents", limit: 4,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_currency", limit: 255, default: "CHF", null: false
  end

  add_index "items", ["invoice_id"], name: "index_items_on_invoice_id", using: :btree

  create_table "options", force: :cascade do |t|
    t.string   "key",        limit: 255, null: false
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "religions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservation_options", force: :cascade do |t|
    t.integer  "reservation_id", limit: 4, null: false
    t.integer  "room_option_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservation_options", ["reservation_id"], name: "index_reservation_options_on_reservation_id", using: :btree
  add_index "reservation_options", ["room_option_id"], name: "index_reservation_options_on_room_option_id", using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer  "resident_id", limit: 4,                       null: false
    t.integer  "room_id",     limit: 4,                       null: false
    t.string   "status",      limit: 255, default: "pending", null: false
    t.date     "arrival",                                     null: false
    t.date     "departure",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["resident_id"], name: "index_reservations_on_resident_id", using: :btree
  add_index "reservations", ["room_id"], name: "index_reservations_on_room_id", using: :btree

  create_table "residents", force: :cascade do |t|
    t.integer  "country_id",     limit: 4
    t.integer  "religion_id",    limit: 4
    t.integer  "school_id",      limit: 4
    t.string   "color",          limit: 255, default: "ffff00"
    t.string   "first_name",     limit: 255,                    null: false
    t.string   "last_name",      limit: 255,                    null: false
    t.string   "gender",         limit: 255
    t.date     "birthdate"
    t.string   "address",        limit: 255
    t.string   "email",          limit: 255
    t.string   "phone",          limit: 255
    t.string   "mobile",         limit: 255
    t.string   "mac_address",    limit: 255
    t.boolean  "mac_active"
    t.string   "identity_card",  limit: 255
    t.string   "bank_name",      limit: 255
    t.string   "bank_iban",      limit: 255
    t.string   "bank_bic_swift", limit: 255
    t.string   "bank_clearing",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "residents", ["country_id"], name: "index_residents_on_country_id", using: :btree
  add_index "residents", ["religion_id"], name: "index_residents_on_religion_id", using: :btree
  add_index "residents", ["school_id"], name: "index_residents_on_school_id", using: :btree

  create_table "rights", force: :cascade do |t|
    t.integer  "group_id",   limit: 4,   null: false
    t.string   "controller", limit: 255, null: false
    t.string   "action",     limit: 255, null: false
    t.boolean  "allowed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rights", ["group_id"], name: "index_rights_on_group_id", using: :btree

  create_table "room_options", force: :cascade do |t|
    t.integer  "room_id",        limit: 4,                   null: false
    t.string   "name",           limit: 255,                 null: false
    t.integer  "value_in_cents", limit: 4,   default: 0,     null: false
    t.string   "billing",        limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_currency", limit: 255, default: "CHF", null: false
  end

  add_index "room_options", ["room_id"], name: "index_room_options_on_room_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "building_id", limit: 4
    t.integer  "rate_id",     limit: 4
    t.string   "name",        limit: 255,                null: false
    t.integer  "size",        limit: 4
    t.string   "phone",       limit: 255
    t.string   "status",      limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",                 default: true
  end

  add_index "rooms", ["building_id"], name: "index_rooms_on_building_id", using: :btree
  add_index "rooms", ["rate_id"], name: "index_rooms_on_rate_id", using: :btree

  create_table "rules", force: :cascade do |t|
    t.integer  "rate_id",              limit: 4,                   null: false
    t.integer  "start_value",          limit: 4
    t.string   "start_type",           limit: 255, default: "0",   null: false
    t.integer  "end_value",            limit: 4
    t.string   "end_type",             limit: 255, default: "0",   null: false
    t.string   "value_type",           limit: 255,                 null: false
    t.integer  "value_in_cents",       limit: 4,   default: 0,     null: false
    t.integer  "tax_in_in_cents",      limit: 4,   default: 0,     null: false
    t.integer  "tax_out_in_cents",     limit: 4,   default: 0,     null: false
    t.integer  "deposit_in_in_cents",  limit: 4,   default: 0,     null: false
    t.integer  "deposit_out_in_cents", limit: 4,   default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_currency",       limit: 255, default: "CHF", null: false
  end

  add_index "rules", ["rate_id"], name: "index_rules_on_rate_id", using: :btree

  create_table "schools", force: :cascade do |t|
    t.integer  "institute_id", limit: 4,   null: false
    t.string   "name",         limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["institute_id"], name: "index_schools_on_institute_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.string   "context",       limit: 128
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "group_id",      limit: 4,   null: false
    t.string   "login",         limit: 255, null: false
    t.string   "password_hash", limit: 255, null: false
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "email",         limit: 255
    t.string   "phone",         limit: 255
    t.string   "mobile",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
