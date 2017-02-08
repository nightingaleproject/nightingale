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

ActiveRecord::Schema.define(version: 20170202142912) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "cause_of_deaths", force: :cascade do |t|
    t.string   "cause"
    t.string   "interval_to_death"
    t.integer  "position"
    t.integer  "death_record_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["death_record_id"], name: "index_cause_of_deaths_on_death_record_id", using: :btree
  end

  create_table "death_certificates", force: :cascade do |t|
    t.string   "decedents_legal_name_first"
    t.string   "decedents_legal_name_middle"
    t.string   "decedents_legal_name_last"
    t.string   "sex"
    t.string   "social_security_number"
    t.date     "date_of_birth"
    t.string   "birthplace_city"
    t.string   "birthplace_state"
    t.string   "birthplace_country"
    t.boolean  "inside_city_limits"
    t.boolean  "ever_in_us_armed_forces"
    t.string   "marital_status_at_time_of_death"
    t.string   "surviving_spouses_name"
    t.string   "fathers_name_first"
    t.string   "fathers_name_middle"
    t.string   "fathers_name_last"
    t.string   "mothers_name_first"
    t.string   "mothers_name_middle"
    t.string   "mothers_name_last"
    t.string   "informants_name_first"
    t.string   "informants_name_middle"
    t.string   "informants_name_last"
    t.string   "informants_relationship_to_decedent"
    t.string   "informants_mailing_address_street_and_number"
    t.string   "informants_mailing_address_city"
    t.string   "informants_mailing_address_state"
    t.string   "informants_mailing_address_zip_code"
    t.string   "place_of_death"
    t.string   "place_of_death_specified"
    t.string   "place_of_death_facility_name"
    t.string   "place_of_death_city"
    t.string   "place_of_death_state"
    t.string   "place_of_death_zip_code"
    t.string   "county_of_death"
    t.string   "method_of_disposition"
    t.string   "method_of_disposition_specified"
    t.string   "place_of_disposition"
    t.string   "place_of_disposition_city"
    t.string   "place_of_disposition_state"
    t.string   "funeral_facility_name"
    t.string   "funeral_facility_street_and_number"
    t.string   "funeral_facility_city"
    t.string   "funeral_facility_state"
    t.string   "funeral_facility_zip"
    t.string   "funeral_director_license_number"
    t.date     "date_pronounced_dead"
    t.time     "time_pronounced_dead"
    t.string   "pronouncing_medical_certifier_license_number"
    t.date     "medical_certifier_date_signed"
    t.date     "actual_or_presumed_date_of_death"
    t.time     "actual_or_presumed_time_of_death"
    t.boolean  "was_medical_examiner_or_coroner_contacted"
    t.string   "cause_of_death_a"
    t.string   "cause_of_death_b"
    t.string   "cause_of_death_c"
    t.string   "cause_of_death_d"
    t.integer  "cause_of_death_approximate_interval_a"
    t.integer  "cause_of_death_approximate_interval_b"
    t.integer  "cause_of_death_approximate_interval_c"
    t.integer  "cause_of_death_approximate_interval_d"
    t.string   "cause_of_death_other_significant_conditions"
    t.boolean  "was_an_autopsy_performed"
    t.boolean  "were_autopsy_findings_available"
    t.string   "did_tobacco_use_contribute_to_death"
    t.string   "pregnancy_status"
    t.string   "manner_of_death"
    t.date     "date_of_injury"
    t.time     "time_of_injury"
    t.string   "place_of_injury"
    t.boolean  "injury_at_work"
    t.string   "location_of_injury_state"
    t.string   "location_of_injury_city"
    t.string   "location_of_injury_street_and_number"
    t.string   "location_of_injury_apartment_number"
    t.string   "location_of_injury_zip_code"
    t.string   "description_of_injury_occurrence"
    t.boolean  "transportation_injury"
    t.string   "transportation_injury_role"
    t.string   "transportation_injury_role_specified"
    t.string   "certifier_type"
    t.string   "medical_certifier_first"
    t.string   "medical_certifier_last"
    t.string   "medical_certifier_state"
    t.string   "medical_certifier_city"
    t.string   "medical_certifier_street_and_number"
    t.string   "medical_certifier_zip_code"
    t.string   "medical_certifier_title"
    t.string   "medical_certifier_license_number"
    t.date     "date_certified"
    t.date     "date_filed"
    t.string   "decedents_education"
    t.string   "decedent_of_hispanic_origin"
    t.string   "decedent_of_hispanic_origin_specified"
    t.string   "decedents_race"
    t.string   "decedents_race_specified"
    t.string   "decedents_usual_occupation"
    t.string   "decedents_kind_of_business_or_industry"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "death_records", force: :cascade do |t|
    t.string   "form_steps",                                      default: [],              array: true
    t.string   "creator_role"
    t.string   "record_status"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffixes"
    t.string   "akas"
    t.string   "social_security_number"
    t.string   "street"
    t.string   "appt_number"
    t.string   "city"
    t.string   "state"
    t.string   "county"
    t.string   "zip_code"
    t.boolean  "inside_city_limits"
    t.string   "spouse_first_name"
    t.string   "spouse_last_name"
    t.string   "spouse_middle_name"
    t.string   "spouse_suffixes"
    t.string   "father_first_name"
    t.string   "father_last_name"
    t.string   "father_middle_name"
    t.string   "father_suffixes"
    t.string   "mother_first_name"
    t.string   "mother_last_name"
    t.string   "mother_middle_name"
    t.string   "mother_suffixes"
    t.string   "sex"
    t.date     "date_of_birth"
    t.string   "birthplace_city"
    t.string   "birthplace_state"
    t.string   "birthplace_country"
    t.string   "ever_in_us_armed_forces"
    t.string   "marital_status_at_time_of_death"
    t.string   "education"
    t.string   "hispanic_origin"
    t.string   "hispanic_origin_explain"
    t.string   "hispanic_origin_other_specify"
    t.string   "race"
    t.string   "race_explain"
    t.string   "race_other_specify"
    t.string   "usual_occupation"
    t.string   "kind_of_business"
    t.string   "method_of_disposition"
    t.string   "method_of_disposition_specified"
    t.string   "place_of_disposition"
    t.string   "place_of_disposition_city"
    t.string   "place_of_disposition_state"
    t.string   "funeral_facility_name"
    t.string   "funeral_facility_street_and_number"
    t.string   "funeral_facility_city"
    t.string   "funeral_facility_state"
    t.string   "funeral_facility_zip"
    t.string   "funeral_facility_county"
    t.string   "funeral_director_license_number"
    t.string   "informants_name_first"
    t.string   "informants_name_middle"
    t.string   "informants_name_last"
    t.string   "informants_suffixes"
    t.string   "informants_mailing_address_street_and_number"
    t.string   "informants_appt_number"
    t.string   "informants_mailing_address_city"
    t.string   "informants_mailing_address_state"
    t.string   "informants_mailing_address_zip_code"
    t.string   "informants_mailing_address_county"
    t.string   "place_of_death_type"
    t.string   "place_of_death_type_specific"
    t.string   "place_of_death_facility_name"
    t.string   "place_of_death_street_number"
    t.string   "place_of_death_appt_number"
    t.string   "place_of_death_city"
    t.string   "place_of_death_state"
    t.string   "place_of_death_county"
    t.string   "place_of_death_zip_code"
    t.time     "time_pronounced_dead"
    t.date     "date_pronounced_dead"
    t.string   "pronouncing_medical_certifier_license_number"
    t.date     "pronouncing_medical_certifier_date_of_signature"
    t.date     "actual_or_presumed_date_of_death"
    t.string   "type_of_date_of_death"
    t.time     "actual_or_presumed_time_of_death"
    t.string   "type_of_time_of_death"
    t.string   "was_medical_examiner_or_coroner_contacted"
    t.boolean  "was_an_autopsy_performed"
    t.boolean  "were_autopsy_findings_available"
    t.string   "did_tobacco_use_contribute_to_death"
    t.string   "pregnancy_status"
    t.string   "manner_of_death"
    t.time     "time_of_injury"
    t.date     "date_of_injury"
    t.boolean  "injury_at_work"
    t.string   "place_of_injury"
    t.string   "location_of_injury_state"
    t.string   "location_of_injury_city"
    t.string   "location_of_injury_street_and_number"
    t.string   "location_of_injury_apartment_number"
    t.string   "location_of_injury_zip_code"
    t.string   "description_of_injury_occurrence"
    t.boolean  "transportation_injury"
    t.string   "transportation_injury_role"
    t.string   "transportation_injury_role_specified"
    t.string   "certifier_type"
    t.string   "medical_certifier_first"
    t.string   "medical_certifier_middle"
    t.string   "medical_certifier_last"
    t.string   "medical_certifier_suffix"
    t.string   "medical_certifier_state"
    t.string   "medical_certifier_city"
    t.string   "medical_certifier_street_and_number"
    t.string   "medical_certifier_apt"
    t.string   "medical_certifier_zip_code"
    t.string   "medical_certifier_county"
    t.string   "medical_certifier_title"
    t.string   "medical_certifier_license_number"
    t.date     "date_certified"
    t.datetime "time_registered"
    t.integer  "registered_by_id"
    t.integer  "certificate_number"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "owner_id"
    t.index ["owner_id"], name: "index_death_records_on_owner_id", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "user_tokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "token_generated_at"
    t.boolean  "is_expired",         default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "user_id"
    t.integer  "death_record_id"
    t.index ["death_record_id"], name: "index_user_tokens_on_death_record_id", using: :btree
    t.index ["user_id"], name: "index_user_tokens_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "is_guest_user",          default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  add_foreign_key "cause_of_deaths", "death_records"
  add_foreign_key "death_records", "users", column: "owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "user_tokens", "death_records"
  add_foreign_key "user_tokens", "users"
end
