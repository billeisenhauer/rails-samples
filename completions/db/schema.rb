# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100618193056) do

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "categories", :force => true do |t|
    t.integer "site_id"
    t.string  "name"
    t.string  "ancestry"
    t.integer "ancestry_depth"
    t.string  "ancestry_names"
  end

  add_index "categories", ["site_id"], :name => "index_categories_on_site_id"

  create_table "imports", :force => true do |t|
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_assets", :force => true do |t|
    t.string   "state"
    t.string   "po_number"
    t.string   "vendor"
    t.string   "rfq_number"
    t.string   "client_name"
    t.string   "project"
    t.boolean  "gr",                      :limit => 255
    t.string   "last_seen_location"
    t.string   "ocs_g"
    t.string   "field"
    t.string   "well"
    t.string   "part_number"
    t.string   "serial_number"
    t.string   "fo"
    t.integer  "quantity_ordered"
    t.integer  "quantity_received"
    t.integer  "measurement_unit"
    t.decimal  "unit_cost_amount",                       :default => 0.0
    t.decimal  "engineering_amount",                     :default => 0.0
    t.decimal  "shipping_amount",                        :default => 0.0
    t.integer  "days_lead_time"
    t.decimal  "total_cost_amount",                      :default => 0.0
    t.decimal  "total_sales_amount",                     :default => 0.0
    t.integer  "cos"
    t.integer  "site_id"
    t.integer  "tag_id"
    t.text     "description"
    t.text     "notes"
    t.text     "custom"
    t.date     "gr_on"
    t.date     "ordered_on"
    t.date     "expected_delivery_on"
    t.date     "actual_delivery_on"
    t.date     "fo_on"
    t.date     "installed_on"
    t.datetime "last_seen_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity_installed"
    t.integer  "quantity_on_location"
    t.string   "recipients"
    t.decimal  "additional_amount",                      :default => 0.0
    t.decimal  "unit_sales_amount",                      :default => 0.0
    t.date     "tr_on"
    t.integer  "parent_asset_id"
    t.integer  "category_id"
    t.integer  "pe_id"
    t.string   "bill_and_hold"
    t.date     "delivery_on"
    t.integer  "tr_assignment_id"
    t.boolean  "tr_status"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "inventory_assets", ["client_name"], :name => "index_assets_on_client_name"
  add_index "inventory_assets", ["field"], :name => "index_inventory_assets_on_field"
  add_index "inventory_assets", ["fo"], :name => "index_inventory_assets_on_fo"
  add_index "inventory_assets", ["installed_on"], :name => "index_assets_on_installed_on"
  add_index "inventory_assets", ["last_seen_location"], :name => "index_inventory_assets_on_last_seen_location"
  add_index "inventory_assets", ["ocs_g"], :name => "index_inventory_assets_on_ocs_g"
  add_index "inventory_assets", ["part_number"], :name => "index_inventory_assets_on_part_number"
  add_index "inventory_assets", ["po_number"], :name => "index_assets_on_po_number"
  add_index "inventory_assets", ["project"], :name => "index_assets_on_project"
  add_index "inventory_assets", ["rfq_number"], :name => "index_assets_on_rfq_number"
  add_index "inventory_assets", ["serial_number"], :name => "index_inventory_assets_on_serial_number"
  add_index "inventory_assets", ["site_id"], :name => "index_assets_on_site_id"
  add_index "inventory_assets", ["state"], :name => "index_assets_on_state"
  add_index "inventory_assets", ["tag_id"], :name => "index_assets_on_tag_id"
  add_index "inventory_assets", ["vendor"], :name => "index_assets_on_vendor"
  add_index "inventory_assets", ["well"], :name => "index_inventory_assets_on_well"

  create_table "notification_conditions", :force => true do |t|
    t.integer "notification_specification_id"
    t.string  "field"
    t.string  "value"
    t.string  "field_type"
    t.string  "operator"
  end

  create_table "notification_recipients", :force => true do |t|
    t.integer "notification_specification_id"
    t.integer "user_id"
  end

  add_index "notification_recipients", ["notification_specification_id"], :name => "index_notification_recipients_on_notification_specification_id"
  add_index "notification_recipients", ["user_id", "notification_specification_id"], :name => "index_notification_recipients_on_user_id_and_notification_specification_id", :unique => true
  add_index "notification_recipients", ["user_id"], :name => "index_notification_recipients_on_user_id"

  create_table "notification_specifications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.integer  "user_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "site_id"
  end

  add_index "site_memberships", ["site_id"], :name => "index_site_memberships_on_site_id"
  add_index "site_memberships", ["user_id", "site_id"], :name => "index_site_memberships_on_user_id_and_site_id", :unique => true
  add_index "site_memberships", ["user_id"], :name => "index_site_memberships_on_user_id"

  create_table "site_statistics", :force => true do |t|
    t.date    "collected_on"
    t.integer "site_id",                        :null => false
    t.integer "active_assets",   :default => 0, :null => false
    t.integer "archived_assets", :default => 0, :null => false
    t.integer "tagged_assets",   :default => 0, :null => false
  end

  add_index "site_statistics", ["site_id"], :name => "index_site_statistics_on_site_id"

  create_table "sites", :force => true do |t|
    t.string  "name"
    t.string  "ancestry"
    t.integer "ancestry_depth"
    t.string  "ancestry_names"
  end

  add_index "sites", ["ancestry"], :name => "index_sites_on_ancestry"

  create_table "tag_readers", :force => true do |t|
    t.integer  "site_id"
    t.string   "reader"
    t.string   "address"
    t.decimal  "latitude",         :precision => 20, :scale => 16
    t.decimal  "longitude",        :precision => 20, :scale => 16
    t.datetime "last_reported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_readers", ["reader"], :name => "index_tag_readers_on_reader"
  add_index "tag_readers", ["site_id"], :name => "index_tag_readers_on_site_id"

  create_table "tag_readings", :force => true do |t|
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_reader_id"
  end

  add_index "tag_readings", ["tag_id"], :name => "index_tag_readings_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string   "tag_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_reported_at"
    t.string   "last_location"
    t.integer  "site_id",             :default => 0
    t.integer  "last_tag_reading_id"
  end

  add_index "tags", ["last_location"], :name => "index_tags_on_last_location"
  add_index "tags", ["last_reported_at"], :name => "index_tags_on_last_reported_at"
  add_index "tags", ["site_id"], :name => "index_tags_on_site_id"
  add_index "tags", ["tag_number"], :name => "index_tags_on_tag_number"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "persistence_token"
    t.integer  "login_count",       :default => 0,                            :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "time_zone",         :default => "Central Time (US & Canada)", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.integer  "role_id"
    t.string   "email"
    t.string   "name"
  end

  add_index "users", ["role_id"], :name => "index_users_on_role_id"
  add_index "users", ["site_id"], :name => "index_users_on_site_id"

end
