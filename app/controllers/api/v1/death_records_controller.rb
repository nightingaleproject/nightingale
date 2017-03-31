# SMART on FHIR API
class Api::V1::DeathRecordsController < UnauthenticatedApplicationController
  def authenticate!
    # TBD:  Add authentication, currently anyone can add users
    # error!('401 Unauthorized', 401) unless current_user
    Rails.logger.debug 'Unauthorized API Access - this is by design, but should be implemented'
  end

  # POST death_record
  def create
    respond_to do |format|
      Rails.logger.debug 'Starting api call to create new decedent'
      authenticate!
      # create death record
      physician_email = params[:physician_email]
      death_record = DeathRecord.new(death_record_params(params))

      if !physician_email
        msg = { status: 'failure', message: 'Bad physician email' }
      else
        physician = User.find_for_authentication(email: physician_email)
        death_record.owner_id = physician.id
        death_record.creator_id = physician.id
        death_record.record_status = 'medical'
        death_record.creator_role = 'physician'
        Rails.logger.debug 'Saving new decedent'
        # save but do not validate for now, as validation will not pass since
        # not all data will be in place
        # TBD:  Consider validation for this scenario
        death_record.save(validate: false)
        msg = { status: 'ok', message: "Successfully added new death record with ID: #{death_record.id}" }
      end

      format.json { render json: msg }
    end
  end

  private

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params(params)
    parameters = params.except(:physician_email)
    parameters.require(:death_record).permit(:record_status,
                                             :first_name,
                                             :middle_name,
                                             :last_name,
                                             :suffixes,
                                             :akas,
                                             :social_security_number,
                                             :street_and_number,
                                             :appt_number,
                                             :city,
                                             :state,
                                             :county,
                                             :zip_code,
                                             :inside_city_limits,
                                             :spouse_first_name,
                                             :spouse_last_name,
                                             :spouse_middle_name,
                                             :spouse_suffixes,
                                             :father_first_name,
                                             :father_last_name,
                                             :father_middle_name,
                                             :father_suffixes,
                                             :mother_first_name,
                                             :mother_last_name,
                                             :mother_middle_name,
                                             :mother_suffixes,
                                             :sex,
                                             :date_of_birth,
                                             :birthplace_city,
                                             :birthplace_state,
                                             :birthplace_country,
                                             :ever_in_us_armed_forces,
                                             :marital_status_at_time_of_death,
                                             :education,
                                             :hispanic_origin,
                                             :hispanic_origin_explain,
                                             :hispanic_origin_other_specify,
                                             :race,
                                             :race_explain,
                                             :race_other_specify,
                                             :usual_occupation,
                                             :kind_of_business,
                                             :method_of_disposition,
                                             :method_of_disposition_specified,
                                             :place_of_disposition,
                                             :place_of_disposition_city,
                                             :place_of_disposition_state,
                                             :funeral_facility_name,
                                             :funeral_facility_street_and_number,
                                             :funeral_facility_city,
                                             :funeral_facility_state,
                                             :funeral_facility_zip,
                                             :funeral_facility_county,
                                             :funeral_director_license_number,
                                             :informants_name_first,
                                             :informants_name_middle,
                                             :informants_name_last,
                                             :informants_suffixes,
                                             :informants_mailing_address_street_and_number,
                                             :informants_appt_number,
                                             :informants_mailing_address_city,
                                             :informants_mailing_address_state,
                                             :informants_mailing_address_zip_code,
                                             :informants_mailing_address_county,
                                             :place_of_death_type,
                                             :place_of_death_type_specific,
                                             :place_of_death_facility_name,
                                             :place_of_death_street_and_number,
                                             :place_of_death_appt_number,
                                             :place_of_death_city,
                                             :place_of_death_state,
                                             :place_of_death_county,
                                             :place_of_death_zip_code,
                                             :time_pronounced_dead,
                                             :date_pronounced_dead,
                                             :pronouncing_medical_certifier_license_number,
                                             :pronouncing_medical_certifier_date_of_signature,
                                             :actual_or_presumed_date_of_death,
                                             :type_of_date_of_death,
                                             :actual_or_presumed_time_of_death,
                                             :type_of_time_of_death,
                                             :was_medical_examiner_or_coroner_contacted,
                                             :was_an_autopsy_performed,
                                             :were_autopsy_findings_available,
                                             :did_tobacco_use_contribute_to_death,
                                             :pregnancy_status,
                                             :manner_of_death,
                                             :time_of_injury,
                                             :date_of_injury,
                                             :injury_at_work,
                                             :place_of_injury,
                                             :location_of_injury_state,
                                             :location_of_injury_city,
                                             :location_of_injury_street_and_number,
                                             :location_of_injury_apartment_number,
                                             :location_of_injury_zip_code,
                                             :description_of_injury_occurrence,
                                             :transportation_injury,
                                             :transportation_injury_role,
                                             :transportation_injury_role_specified,
                                             :certifier_type,
                                             :medical_certifier_first,
                                             :medical_certifier_middle,
                                             :medical_certifier_last,
                                             :medical_certifier_suffix,
                                             :medical_certifier_state,
                                             :medical_certifier_city,
                                             :medical_certifier_street_and_number,
                                             :medical_certifier_apt,
                                             :medical_certifier_zip_code,
                                             :medical_certifier_county,
                                             :medical_certifier_title,
                                             :medical_certifier_license_number,
                                             :date_certified,
                                             :time_registered,
                                             :registered_by_id,
                                             :certificate_number,
                                             :owner_id,
                                             :date_certified,
                                             cause_of_death_attributes: [:cause, :interval_to_death, :position])
  end
end
