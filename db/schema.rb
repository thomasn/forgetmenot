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

ActiveRecord::Schema.define(:version => 20090718134257) do

  create_table "activities", :force => true do |t|
    t.integer  "activity_type_id"
    t.datetime "time"
    t.text     "notes"
    t.integer  "user_id"
  end

  add_index "activities", ["activity_type_id"], :name => "index_activities_on_activity_type_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "activities_contacts", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "contact_id"
  end

  add_index "activities_contacts", ["activity_id"], :name => "index_activities_contacts_on_activity_id"
  add_index "activities_contacts", ["contact_id"], :name => "index_activities_contacts_on_contact_id"

  create_table "activity_types", :force => true do |t|
    t.string "name"
  end

  create_table "addresses", :force => true do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
  end

  create_table "contacts", :force => true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone_number"
    t.string  "title"
    t.string  "work_phone"
    t.string  "mobile_phone"
    t.string  "home_phone"
    t.string  "other_phone"
    t.string  "fax"
    t.boolean "do_not_email"
    t.boolean "do_not_phone"
    t.text    "notes"
    t.integer "address_id"
    t.integer "address2_id"
    t.integer "lead_source_id"
    t.boolean "delta",          :default => true, :null => false
  end

  add_index "contacts", ["address2_id"], :name => "index_contacts_on_address2_id"
  add_index "contacts", ["address_id"], :name => "index_contacts_on_address_id"
  add_index "contacts", ["lead_source_id"], :name => "index_contacts_on_lead_source_id"

  create_table "contacts_groups", :id => false, :force => true do |t|
    t.integer "contact_id"
    t.integer "group_id"
  end

  add_index "contacts_groups", ["contact_id"], :name => "index_contacts_groups_on_contact_id"
  add_index "contacts_groups", ["group_id"], :name => "index_contacts_groups_on_group_id"

  create_table "dynamic_attribute_values", :force => true do |t|
    t.integer  "dynamic_attribute_id"
    t.integer  "contact_id"
    t.string   "string_value"
    t.text     "text_value"
    t.integer  "integer_value"
    t.decimal  "decimal_value"
    t.datetime "datetime_value"
    t.boolean  "boolean_value"
  end

  add_index "dynamic_attribute_values", ["contact_id"], :name => "index_dynamic_attribute_values_on_contact_id"
  add_index "dynamic_attribute_values", ["dynamic_attribute_id"], :name => "index_dynamic_attribute_values_on_dynamic_attribute_id"

  create_table "dynamic_attributes", :force => true do |t|
    t.string "name"
    t.string "type_name"
  end

  add_index "dynamic_attributes", ["name"], :name => "index_dynamic_attributes_on_name"

  create_table "email_messages", :force => true do |t|
    t.integer "activity_id"
    t.string  "subject"
    t.text    "body"
  end

  create_table "group_types", :force => true do |t|
    t.string "name"
  end

  create_table "groups", :force => true do |t|
    t.string  "name"
    t.integer "account_number"
    t.string  "phone"
    t.string  "fax"
    t.string  "website"
    t.text    "notes"
    t.integer "billing_address_id"
    t.integer "shipping_address_id"
    t.integer "group_type_id"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "root_id"
    t.integer "depth"
  end

  add_index "groups", ["billing_address_id"], :name => "index_groups_on_billing_address_id"
  add_index "groups", ["group_type_id"], :name => "index_groups_on_group_type_id"
  add_index "groups", ["lft"], :name => "index_groups_on_lft"
  add_index "groups", ["parent_id"], :name => "index_groups_on_parent_id"
  add_index "groups", ["rgt"], :name => "index_groups_on_rgt"
  add_index "groups", ["root_id"], :name => "index_groups_on_root_id"
  add_index "groups", ["shipping_address_id"], :name => "index_groups_on_shipping_address_id"

  create_table "lead_sources", :force => true do |t|
    t.string "name"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["crypted_password", "login"], :name => "index_users_on_login_and_crypted_password"

end
