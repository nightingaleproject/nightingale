class CreateDeathRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :death_records do |t|

      ### Step Order
      t.string :form_steps, array: true, default: []
      t.string :creator_role

      ### Identity information
      t.string :record_status
      t.string :first_name, :middle_name, :last_name
      t.string :suffixes
      t.string :akas
      t.string :social_security_number

      # Decedent's Residence
      t.string :street, :appt_number, :city, :state, :county, :zip_code
      t.boolean :inside_city_limits

      # Decedent's Spouse Information
      t.string :spouse_first_name, :spouse_last_name, :spouse_middle_name, :spouse_suffixes

      # Decedent's Father Information
      t.string :father_first_name, :father_last_name, :father_middle_name, :father_suffixes

      # Decedent's Mother Information
      t.string :mother_first_name, :mother_last_name, :mother_middle_name, :mother_suffixes

      ### Demographics

      t.string :sex
      t.date :date_of_birth

      # Birth Place Information
      t.string :birthplace_city, :birthplace_state, :birthplace_country

      t.string :ever_in_us_armed_forces

      # MARITAL STATUS AT TIME OF DEATH Married / Married, but separated / Widowed / Divorced / Never Married / Unknown
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
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

      # Disposition Information
      # 18. METHOD OF DISPOSITION: Burial / Cremation / Donation / Entombment / Removal from State / Other (Specify)
      t.string :method_of_disposition, :method_of_disposition_specified

      # 19. PLACE OF DISPOSITION (Name of cemetery, crematory, other place)
      t.string :place_of_disposition

      # 20. LOCATION-CITY, TOWN, AND STATE
      t.string :place_of_disposition_city, :place_of_disposition_state

      # 21. NAME AND COMPLETE ADDRESS OF FUNERAL FACILITY
      t.string :funeral_facility_name, :funeral_facility_street_and_number, :funeral_facility_city, :funeral_facility_state,
               :funeral_facility_zip, :funeral_facility_county

        # 23. LICENSE NUMBER (Of Licensee)
      t.string :funeral_director_license_number

      # 13a. INFORMANT’S NAME
      t.string :informants_name_first, :informants_name_middle, :informants_name_last, :informants_suffixes

      # 13c. MAILING ADDRESS (Street and Number, City, State, Zip Code)
      t.string :informants_mailing_address_street_and_number, :informants_appt_number, :informants_mailing_address_city, :informants_mailing_address_state,
               :informants_mailing_address_zip_code, :informants_mailing_address_county

      # Place of Death (notes from standard cert):
      # PLACE OF DEATH (Check only one: see instructions)
      # IF DEATH OCCURRED IN A HOSPITAL: Inpatient / Emergency Room/Outpatient / Dead on Arrival
      # IF DEATH OCCURRED SOMEWHERE OTHER THAN A HOSPITAL: Hospice facility / Nursing home/Long term care facility /
      # Decedent’s home / Other (Specify)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :place_of_death_type, :place_of_death_type_specific
      t.string :place_of_death_facility_name
      t.string :place_of_death_street_number, :place_of_death_appt_number, :place_of_death_city,
        :place_of_death_state, :place_of_death_county, :place_of_death_zip_code

      # Date/time of death
      # TODO: We may want to combine date and time into a datetime field
      t.time :time_pronounced_dead
      t.date :date_pronounced_dead

      # TODO: We may want to model this as a relationship to a separate medical_certifier
      # TODO: We need to be clear on how this is distinct from #48
      t.string :pronouncing_medical_certifier_license_number

      t.date :pronouncing_medical_certifier_date_of_signature

      # actual or presumed date/time of death
      # TODO: We may want to combine date and time into a datetime field
      t.date :actual_or_presumed_date_of_death
      t.string :type_of_date_of_death
      t.time :actual_or_presumed_time_of_death
      t.string :type_of_time_of_death

      t.string :was_medical_examiner_or_coroner_contacted
      t.boolean :was_an_autopsy_performed
      t.boolean :were_autopsy_findings_available

      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :did_tobacco_use_contribute_to_death

      # Pregnancy status (notes from standard cert):
      # IF FEMALE: Not pregnant within past year / Pregnant at time of death / Not pregnant, but pregnant within 42 days of death /
      # Not pregnant, but pregnant 43 days to 1 year before death /  Unknown if pregnant within the past year
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :pregnancy_status

      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :manner_of_death

      # Date/time of injury
      # TODO: We may want to combine date and time into a datetime field
      t.time :time_of_injury
      t.date :date_of_injury

      # This has values of 'yes', 'no', and 'unknown'  Still modeled as a boolean
      # 'unknown' is null
      t.boolean :injury_at_work

      #PLACE OF INJURY (e.g., Decedent’s home; construction site; restaurant; wooded area)
      t.string :place_of_injury

      t.string :location_of_injury_state, :location_of_injury_city, :location_of_injury_street_and_number, :location_of_injury_apartment_number,
               :location_of_injury_zip_code
      t.string :description_of_injury_occurrence
      t.boolean :transportation_injury
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :transportation_injury_role, :transportation_injury_role_specified

      # 45. CERTIFIER (Check only one)

      # Certifying physician: To the best of my knowledge, death occurred due to the cause(s) and manner
      # stated.

      # Pronouncing & Certifying physician: To the best of my knowledge, death occurred at the time, date, and
      # place, and due to the cause(s) and manner stated.

      # Medical Examiner/Coroner-On the basis of examination, and/or investigation, in my opinion, death
      # occurred at the time, date, and place, and due to the cause(s) and manner stated.

      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :certifier_type

      # Signature of certifier
      # TODO: Need to determine approach for digital signatures (voice, fax, etc)

      # 46. NAME, ADDRESS, AND ZIP CODE OF PERSON COMPLETING CAUSE OF DEATH (Item 32)
      # TODO: We likely want to model this as a relationship to a separate medical_certifier
      t.string :medical_certifier_first, :medical_certifier_middle, :medical_certifier_last, :medical_certifier_suffix, :medical_certifier_state, :medical_certifier_city, :medical_certifier_street_and_number,
               :medical_certifier_apt, :medical_certifier_zip_code, :medical_certifier_county

      # 47. TITLE OF CERTIFIER
      # TODO: We likely want to model this as a relationship to a separate medical_certifier
      t.string :medical_certifier_title

      # 48. LICENSE NUMBER
      # TODO: We may want to model this as a relationship to a separate medical_certifier
      t.string :medical_certifier_license_number

      t.date :date_certified

      # registration fields
      t.timestamp :time_registered
      t.integer :registered_by_id
      t.integer :certificate_number

      t.timestamps
    end
  end
end
