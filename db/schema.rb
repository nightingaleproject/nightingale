# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_28_122404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "certificate_requests", id: :serial, force: :cascade do |t|
    t.integer "death_certificate_id"
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_certificate_requests_on_creator_id"
    t.index ["death_certificate_id"], name: "index_certificate_requests_on_death_certificate_id"
  end

  create_table "cities", id: :serial, force: :cascade do |t|
    t.integer "state_id"
    t.integer "county_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["county_id"], name: "index_cities_on_county_id"
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "death_record_id"
    t.integer "user_id"
    t.string "content"
    t.boolean "requested_edits", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["death_record_id"], name: "index_comments_on_death_record_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "counties", id: :serial, force: :cascade do |t|
    t.integer "state_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_counties_on_state_id"
  end

  create_table "death_certificates", id: :serial, force: :cascade do |t|
    t.binary "document"
    t.json "metadata", default: {}
    t.integer "death_record_id"
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_death_certificates_on_creator_id"
    t.index ["death_record_id"], name: "index_death_certificates_on_death_record_id"
  end

  create_table "death_records", id: :serial, force: :cascade do |t|
    t.integer "workflow_id"
    t.integer "owner_id"
    t.integer "creator_id"
    t.integer "step_flow_id"
    t.string "name", default: ""
    t.json "contents", default: {}
    t.json "cached_json"
    t.boolean "notify", default: false
    t.boolean "abandoned", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_death_records_on_creator_id"
    t.index ["owner_id"], name: "index_death_records_on_owner_id"
    t.index ["step_flow_id"], name: "index_death_records_on_step_flow_id"
    t.index ["workflow_id"], name: "index_death_records_on_workflow_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "registrations", id: :serial, force: :cascade do |t|
    t.integer "death_record_id"
    t.datetime "registered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["death_record_id"], name: "index_registrations_on_death_record_id"
  end

  create_table "role_permissions", id: :serial, force: :cascade do |t|
    t.string "role"
    t.boolean "can_start_record"
    t.boolean "can_register_record"
    t.boolean "can_request_edits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "states", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbrv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "step_contents", id: :serial, force: :cascade do |t|
    t.integer "step_id"
    t.integer "death_record_id"
    t.integer "editor_id"
    t.json "contents", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["death_record_id"], name: "index_step_contents_on_death_record_id"
    t.index ["editor_id"], name: "index_step_contents_on_editor_id"
    t.index ["step_id"], name: "index_step_contents_on_step_id"
  end

  create_table "step_flows", id: :serial, force: :cascade do |t|
    t.integer "workflow_id"
    t.string "current_step_role"
    t.string "send_to_role"
    t.integer "current_step_id"
    t.integer "next_step_id"
    t.integer "previous_step_id"
    t.integer "transition_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_step_id"], name: "index_step_flows_on_current_step_id"
    t.index ["next_step_id"], name: "index_step_flows_on_next_step_id"
    t.index ["previous_step_id"], name: "index_step_flows_on_previous_step_id"
    t.index ["workflow_id"], name: "index_step_flows_on_workflow_id"
  end

  create_table "step_histories", id: :serial, force: :cascade do |t|
    t.integer "step_id"
    t.integer "death_record_id"
    t.integer "user_id"
    t.float "time_taken"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["death_record_id"], name: "index_step_histories_on_death_record_id"
    t.index ["step_id"], name: "index_step_histories_on_step_id"
    t.index ["user_id"], name: "index_step_histories_on_user_id"
  end

  create_table "step_statuses", id: :serial, force: :cascade do |t|
    t.integer "death_record_id"
    t.integer "current_step_id"
    t.integer "next_step_id"
    t.integer "previous_step_id"
    t.integer "requestor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_step_id"], name: "index_step_statuses_on_current_step_id"
    t.index ["death_record_id"], name: "index_step_statuses_on_death_record_id"
    t.index ["next_step_id"], name: "index_step_statuses_on_next_step_id"
    t.index ["previous_step_id"], name: "index_step_statuses_on_previous_step_id"
    t.index ["requestor_id"], name: "index_step_statuses_on_requestor_id"
  end

  create_table "steps", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbrv"
    t.string "description"
    t.string "version"
    t.json "jsonschema"
    t.json "uischema"
    t.string "icon"
    t.string "step_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_tokens", id: :serial, force: :cascade do |t|
    t.integer "death_record_id"
    t.integer "user_id"
    t.string "token"
    t.datetime "token_generated_at"
    t.boolean "is_expired", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["death_record_id"], name: "index_user_tokens_on_death_record_id"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "is_guest_user", default: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "telephone", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "workflows", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "initiator_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zipcodes", id: :serial, force: :cascade do |t|
    t.integer "state_id"
    t.integer "county_id"
    t.integer "city_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_zipcodes_on_city_id"
    t.index ["county_id"], name: "index_zipcodes_on_county_id"
    t.index ["state_id"], name: "index_zipcodes_on_state_id"
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
end
