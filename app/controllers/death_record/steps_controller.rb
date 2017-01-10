# Step Controller
class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  before_action :set_steps
  before_action :setup_wizard

  def show
    authorize :step, :show?
    @death_record = DeathRecord.find(params[:death_record_id])

    # TODO: Should be able to move this logic or remove it.
    if step.to_sym == :reg_send
      @users_with_roles = User.with_any_role(:registrar)
      @title = 'Select Registrar'
    elsif step.to_sym == :send_to_medical_professional
      @users_with_roles = User.with_any_role(:physician, :medical_examiner)
      @title = 'Select Medical Professional'
    elsif step.to_sym == :send_to_funeral_director
      @users_with_roles = User.with_any_role(:funeral_director)
      @title = 'Select Funeral Director'
    end
    render_wizard
  end

  def update
    @death_record = DeathRecord.find(params[:death_record_id])
    @death_record.record_status = next_step
    @death_record.update(death_record_params(step))
    # Special Case when transfering ownership from Funeral director to physician or ME or Registrar
    if step.include? 'send'
      redirect_to root_path
      return
    end
    render_wizard @death_record
  end

  private

  # Set the steps for the multipage form from the steps set on the death record model
  def set_steps
    self.steps = DeathRecord.find(params[:death_record_id]).form_steps
  end

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params(step)
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
