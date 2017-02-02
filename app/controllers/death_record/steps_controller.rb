# Step Controller
class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  before_action :set_steps
  before_action :setup_wizard

  def show
    # Authorization file in step_policy.rb show function.
    # TODO: Documentation on which views are possible based on the possible steps.
    # List of steps for User's Role can be found in (Step list can be found in (/config/steps/steps_config.yml)
    # Wicked uses the current step's name to match it to a corresponding erb file in (/views/death_record/steps/)
    authorize :step, :show?
    @death_record = DeathRecord.find(params[:death_record_id])

    # TODO: Should be able to move this logic or remove it.
    if step.to_sym == :send_to_registrar
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
    # Policy function update in step_policy.rb
    authorize :step, :update?
    @death_record = DeathRecord.find(params[:death_record_id])
    @death_record.record_status = next_step
    @death_record.update(death_record_params(step))

    # Special Case when transfering ownership from Funeral director to physician or ME or Registrar
    # Instead of directing to the next step screen, we send the user back to the home dashboard
    # becasue they no longer are owners of the death record
    if step.start_with? 'send'
      # TODO: Should we allow guest users to send the record to another guest user??!
      # Check if owner is guest user sending it to an existing user.
      if @death_record.owner_id.nil? && params[:owner_email] != ''
        @guest_user = generate_unregistered_user(params[:owner_email])
        @guest_token = generate_user_token(@guest_user.id, @death_record.id)
        @death_record.owner_id = @guest_user.id

        # TODO: Send email
        puts 'HERE IS THE LINK'
        puts @guest_token
        puts login_link(@guest_token, @death_record)
      end

      # Check if old owner is guest user.
      # Invalidate token by using a table that matches record id + token id + user id.
      # Logs guest user out.
      if current_user.is_guest_user
        guest_token = UserToken.where(death_record_id: @death_record.id, user_id: current_user.id).first
        guest_token.expire_token!
        sign_out(current_user)
      end

      redirect_to root_path
      return
    end
    render_wizard @death_record
  end

  private

 # Generates a new user with no password but with a token.
  def generate_unregistered_user (email)
    # TODO: Add authorization
    @user = User.new(email: email, password: '')
    @user.is_guest_user = true
    @user.skip_confirmation!
    @user.add_role :guest_user
    @user.save(validate: false)
    return @user
  end

  def generate_user_token (user_id, death_record_id)
    @guest_token = UserToken.new(user_id: user_id, death_record_id: death_record_id)
    @guest_token.new_token!
    @guest_token.save
    return @guest_token
  end

  def send_login_link
    template = 'login_link'
    UserMailer.send(template).deliver_now
  end

  def login_link(user_token, death_record)
    "http://localhost:3000/guest_users/#{user_token.token}"
  end

  # If token is attached, change current user to user with given token. Check if token is valid. If not delete
  def check_user()

  end

  # Set the steps for the multipage form from the steps set on the death record model
  def set_steps
    self.steps = APP_CONFIG[DeathRecord.find(params[:death_record_id]).creator_role]
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
                                         :owner_id,
                                         :date_certified).merge(form_step: step)
  end
end
