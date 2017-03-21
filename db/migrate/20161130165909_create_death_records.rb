class CreateDeathRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :death_records do |t|

      #########################################################################
      # Record information
      #########################################################################

      t.string :form_steps, array: true, default: []

      t.string :creator_role
      t.integer :creator_id
      t.string :record_status
      t.boolean :voided


      #########################################################################
      # Identity information
      #########################################################################

      t.string :first_name, :middle_name, :last_name
      t.string :suffixes
      t.string :first_name_aka, :middle_name_aka, :last_name_aka, :suffixes_aka
      t.string :social_security_number

      t.string :street_and_number, :apt, :city, :state, :county, :zip_code
      t.boolean :inside_city_limits

      t.string :spouse_first_name, :spouse_last_name, :spouse_middle_name, :spouse_suffixes

      t.string :father_first_name, :father_last_name, :father_middle_name, :father_suffixes

      t.string :mother_first_name, :mother_last_name, :mother_middle_name, :mother_suffixes


      #########################################################################
      # Demographics
      #########################################################################

      t.string :sex
      t.date :date_of_birth

      t.string :birthplace_city, :birthplace_state, :birthplace_country

      t.string :ever_in_us_armed_forces

      t.string :marital_status_at_time_of_death
      t.string :education

      t.string :hispanic_origin
      t.string :hispanic_origin_explain
      t.string :hispanic_origin_other_specify

      t.string :race
      t.string :race_explain
      t.string :race_other_specify

      t.string :usual_occupation
      t.string :kind_of_business


      #########################################################################
      # Disposition information
      #########################################################################

      t.string :method_of_disposition, :method_of_disposition_specified

      t.string :place_of_disposition

      t.string :place_of_disposition_city, :place_of_disposition_state

      t.string :funeral_facility_name, :funeral_facility_street_and_number, :funeral_facility_city, :funeral_facility_state,
               :funeral_facility_zip_code, :funeral_facility_county

      t.string :funeral_director_license_number

      t.string :informants_name_first, :informants_name_middle, :informants_name_last, :informants_suffixes

      t.string :informants_mailing_address_street_and_number, :informants_mailing_address_apt, :informants_mailing_address_city, :informants_mailing_address_state,
               :informants_mailing_address_zip_code, :informants_mailing_address_county


      #########################################################################
      # Medical information
      #########################################################################

      t.string :place_of_death_type, :place_of_death_type_specific
      t.string :place_of_death_facility_name
      t.string :place_of_death_street_and_number, :place_of_death_apt, :place_of_death_city,
        :place_of_death_state, :place_of_death_county, :place_of_death_zip_code

      t.time :time_pronounced_dead
      t.date :date_pronounced_dead

      t.string :pronouncing_medical_certifier_license_number

      t.date :pronouncing_medical_certifier_date_of_signature

      t.date :actual_or_presumed_date_of_death
      t.string :type_of_date_of_death
      t.time :actual_or_presumed_time_of_death
      t.string :type_of_time_of_death

      t.string :was_medical_examiner_or_coroner_contacted
      t.boolean :was_an_autopsy_performed
      t.boolean :were_autopsy_findings_available

      t.string :did_tobacco_use_contribute_to_death

      t.string :pregnancy_status

      t.string :manner_of_death

      t.time :time_of_injury
      t.date :date_of_injury

      t.boolean :injury_at_work

      t.string :place_of_injury

      t.string :location_of_injury_state, :location_of_injury_city, :location_of_injury_street_and_number, :location_of_injury_apt,
               :location_of_injury_zip_code
      t.string :description_of_injury_occurrence
      t.boolean :transportation_injury
      t.string :transportation_injury_role, :transportation_injury_role_specified

      t.string :certifier_type

      t.string :medical_certifier_first, :medical_certifier_middle, :medical_certifier_last, :medical_certifier_suffix, :medical_certifier_state, :medical_certifier_city, :medical_certifier_street_and_number,
               :medical_certifier_apt, :medical_certifier_zip_code, :medical_certifier_county

      t.string :medical_certifier_title

      t.string :medical_certifier_license_number

      t.date :date_certified


      #########################################################################
      # Registration information
      #########################################################################

      t.timestamp :time_registered
      t.integer :registered_by_id
      t.integer :certificate_number

      t.timestamps
    end
  end
end
