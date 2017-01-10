# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :authenticate_user!, :set_death_record, only: [:show, :destroy, :update]

  def index
    @death_records = policy_scope(DeathRecord)
  end

  def show
    # TODO: if not logged in, redirect to login.
  end

  def destroy
    authorize DeathRecord
    @death_record.destroy unless @death_record.nil?
    redirect_to root_path
  end

  def create
    authorize DeathRecord
    @death_record = DeathRecord.new
    @death_record.user_id = current_user[:id]

    # TODO: Add steps to a config file based on role?
    if current_user.has_role? :funeral_director
      @death_record.form_steps = [:identity, :demographics, :disposition, :send_to_medical_professional, :medical, :reg_send]
      @death_record.creator_role = :funeral_director
    elsif current_user.has_role? :physician
      @death_record.form_steps = [:medical, :send_to_funeral_director, :identity, :demographics, :disposition, :reg_send]
      @death_record.creator_role = :physician
    else
      @death_record.form_steps = [:identity, :demographics, :disposition, :medical, :reg_send]
      @death_record.creator_role = :other
    end

    @death_record.record_status = @death_record.form_steps.first
    @death_record.save(validate: false)
    redirect_to death_record_step_path(@death_record, @death_record.form_steps.first)
  end

  def update
    authorize DeathRecord
    time_registered = Time.now.getlocal
    registered_by_id = current_user.id
    max_cert = DeathRecord.maximum('certificate_number')
    # starting certificate numbers at 10000 for now
    # TODO:  Confirm starting number and/or (likely) put this in a config file somewhere
    certificate_number = max_cert ? max_cert + 1 : 10_000

    if !@death_record.update_attributes(time_registered: time_registered,
                                        registered_by_id: registered_by_id,
                                        certificate_number: certificate_number,
                                        was_an_autopsy_performed: true,
                                        were_autopsy_findings_available: true)
      logger.debug(@death_record.errors.inspect)
    else
      flash[:notice] = 'Successfully registered'
    end

    redirect_to action: 'show', id: @death_record.id
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_death_record
    @death_record = DeathRecord.find(params[:id])
  end

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params
    params.require(:death_record).permit(:record_status,
                                         :first_name,
                                         :middle_name,
                                         :last_name,
                                         :suffixes,
                                         :akas,
                                         :social_security_number,
                                         :street,
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
                                         :place_of_death_street_number,
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
                                         :first_name,
                                         :last_name,
                                         :social_security_number,
                                         :street,
                                         :city,
                                         :state,
                                         :county,
                                         :zip_code,
                                         :inside_city_limits,
                                         :father_first_name,
                                         :father_last_name,
                                         :mother_first_name,
                                         :mother_last_name,
                                         :sex,
                                         :date_of_birth,
                                         :birthplace_city,
                                         :birthplace_state,
                                         :birthplace_country,
                                         :ever_in_us_armed_forces,
                                         :marital_status_at_time_of_death,
                                         :education,
                                         :hispanic_origin,
                                         :race,
                                         :usual_occupation,
                                         :kind_of_business,
                                         :method_of_disposition,
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
                                         :informants_name_last,
                                         :informants_mailing_address_street_and_number,
                                         :informants_mailing_address_city,
                                         :informants_mailing_address_state,
                                         :informants_mailing_address_zip_code,
                                         :informants_mailing_address_county,
                                         :place_of_death_type,
                                         :place_of_death_facility_name,
                                         :place_of_death_street_number,
                                         :place_of_death_city,
                                         :place_of_death_state,
                                         :place_of_death_zip_code,
                                         :place_of_death_county,
                                         :date_pronounced_dead,
                                         :time_pronounced_dead,
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
                                         :medical_certifier_first,
                                         :medical_certifier_last,
                                         :medical_certifier_street_and_number,
                                         :medical_certifier_city,
                                         :medical_certifier_state,
                                         :medical_certifier_zip_code,
                                         :medical_certifier_county,
                                         :medical_certifier_license_number,
                                         :certifier_type,
                                         :user_id,
                                         :date_certified).merge(form_step: step)
  end
end
