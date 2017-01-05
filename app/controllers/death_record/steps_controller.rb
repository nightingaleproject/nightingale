# Step Controller
class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  steps(*DeathRecord.form_steps)

  def show
    authorize :step, :show?
    @death_record = DeathRecord.find(params[:death_record_id])
    case step.to_sym
    when :fd_to_me
      @users_with_medical_roles = User.with_any_role(:physician, :medical_examiner)
    when :medical
      @registrars = User.with_any_role(:registrar)
    end
    render_wizard
  end

  def update
    @death_record = DeathRecord.find(params[:death_record_id])
    @death_record.record_status = next_step
    @death_record.update(death_record_params)
    # Special Case when transfering ownership from Funeral director to physician or ME
    if step == 'fd_to_me'
      redirect_to root_path
      return
    end
    render_wizard @death_record
  end

  private

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params
    params.require(:death_record).permit(:decedents_legal_name_first,
                                         :decedents_legal_name_middle,
                                         :decedents_legal_name_last,
                                         :sex,
                                         :social_security_number,
                                         :date_of_birth,
                                         :birthplace_city,
                                         :birthplace_state,
                                         :birthplace_country,
                                         :inside_city_limits,
                                         :ever_in_us_armed_forces,
                                         :marital_status_at_time_of_death,
                                         :surviving_spouses_name,
                                         :fathers_name_first,
                                         :fathers_name_middle,
                                         :fathers_name_last,
                                         :mothers_name_first,
                                         :mothers_name_middle,
                                         :mothers_name_last,
                                         :informants_name_first,
                                         :informants_name_middle,
                                         :informants_name_last,
                                         :informants_relationship_to_decedent,
                                         :informants_mailing_address_street_and_number,
                                         :informants_mailing_address_city,
                                         :informants_mailing_address_state,
                                         :informants_mailing_address_zip_code,
                                         :place_of_death,
                                         :place_of_death_specified,
                                         :place_of_death_facility_name,
                                         :place_of_death_city,
                                         :place_of_death_state,
                                         :place_of_death_zip_code,
                                         :county_of_death,
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
                                         :funeral_director_license_number,
                                         :date_pronounced_dead,
                                         :time_pronounced_dead,
                                         :pronouncing_medical_certifier_license_number,
                                         :medical_certifier_date_signed,
                                         :actual_or_presumed_date_of_death,
                                         :actual_or_presumed_time_of_death,
                                         :was_medical_examiner_or_coroner_contacted,
                                         :cause_of_death_a,
                                         :cause_of_death_b,
                                         :cause_of_death_c,
                                         :cause_of_death_d,
                                         :cause_of_death_approximate_interval_a,
                                         :cause_of_death_approximate_interval_b,
                                         :cause_of_death_approximate_interval_c,
                                         :cause_of_death_approximate_interval_d,
                                         :cause_of_death_other_significant_conditions,
                                         :was_an_autopsy_performed,
                                         :were_autopsy_findings_available,
                                         :did_tobacco_use_contribute_to_death,
                                         :pregnancy_status,
                                         :manner_of_death,
                                         :date_of_injury,
                                         :time_of_injury,
                                         :place_of_injury,
                                         :injury_at_work,
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
                                         :medical_certifier_last,
                                         :medical_certifier_state,
                                         :medical_certifier_city,
                                         :medical_certifier_street_and_number,
                                         :medical_certifier_zip_code,
                                         :medical_certifier_title,
                                         :medical_certifier_license_number,
                                         :date_certified,
                                         :date_filed,
                                         :decedents_education,
                                         :decedent_of_hispanic_origin,
                                         :decedent_of_hispanic_origin_specified,
                                         :decedents_race,
                                         :decedents_race_specified,
                                         :decedents_usual_occupation,
                                         :decedents_kind_of_business_or_industry)
  end
end
