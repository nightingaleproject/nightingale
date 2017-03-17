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

    # Grab supplemental questions for this step
    @questions = Question::Question.where(step: step.to_s).to_a
    render_wizard
  end

  def update
    # Policy function update in step_policy.rb
    authorize :step, :update?
    @death_record = DeathRecord.find(params[:death_record_id])
    old_step = @death_record.record_status
    old_updated_time = @death_record.updated_at
    @death_record.record_status = next_step

    # Grab supplemental questions for this step
    @questions = Question::Question.where(step: step.to_s).to_a

    # Create an answer for every question; if wasn't answered trigger a
    # validation error for required supplemental questions.
    @questions.each do |question|
      field_name = 'question' + question.id.to_s
      result = params[field_name]
      if question.required && !question.valid_answer(result)
        @error = true
      else
        # Create a new answer
        answer = Answer::Answer.new
        answer.answer = params['question' + question.id.to_s]
        answer.death_record_id = @death_record.id
        answer.question_id = question.id
        answer.question = question.question
        answer.save!
      end
    end

    @death_record.supplemental_error_flag = !(@error.nil? || !@error)

    # Update the death record
    if !@death_record.update(death_record_params(step))
      flash[:danger] = 'There were error(s) with your submission, please see below.'
    else
      flash[:danger].clear unless flash[:danger].nil?
      # Create new StepTimeTaken, used for calculating averages for statistics
      sta = StepTimeTaken.new(step: old_step, user_id: current_user.id, time_taken: (@death_record.updated_at - old_updated_time) / 60)
      sta.save!
    end

    # Special Case when transfering ownership from Funeral director to physician or ME or Registrar
    # Instead of directing to the next step screen, we send the user back to the home dashboard
    # becasue they no longer are owners of the death record
    if step.start_with? 'send'
      # TODO: Should we allow guest users to send the record to another guest user??!
      # Death record owner_id gets set in the view if they use the drop down.
      # This check confirms that they did not select a user from the drop down list.
      # Check if owner is guest user sending it to an existing user.
      if @death_record.owner_id.nil? && params[:owner_email] != ''
        @guest_user = generate_user(params[:owner_email], params[:owner_first_name], params[:owner_last_name], params[:owner_telephone], step)
        @guest_token = generate_user_token(@guest_user.id, @death_record.id)
        @death_record.owner_id = @guest_user.id

        # TODO: Send email
        login_link = generate_login_link(@guest_token)
        send_login_link(@guest_user, login_link)
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
  # If a user already exists with that email, return the existing user.
  def generate_user(email, first_name, last_name, telephone, step)
    # TODO: What should the role be of the guest user?
    user = User.where(email: email).first
    unless user.present?
      user = User.new(email: email, password: '', first_name: first_name, last_name: last_name, telephone: telephone)
      user.is_guest_user = true
      user.skip_confirmation!

      # Assuming guest_user's role based on step.
      if step.to_sym == :send_to_medical_professional
        user.add_role 'physician' # :medical_examiner TODO: How do we determine if its physician or medical_examiner
      elsif step.to_sym == :send_to_funeral_director
        user.add_role 'funeral_director'
      end
      user.save(validate: false)
    end

    user
  end

  def generate_user_token(user_id, death_record_id)
    @guest_token = UserToken.new(user_id: user_id, death_record_id: death_record_id)
    @guest_token.new_token!
    @guest_token.save
    @guest_token
  end

  def send_login_link(guest_user, login_link)
    GuestMailer.guest_user_email(guest_user, login_link).deliver_later
  end

  def generate_login_link(user_token)
    root_url + "guest_users/#{user_token.token}"
  end

  # Set the steps for the multipage form from the steps set on the death record model
  def set_steps
    self.steps = APP_CONFIG[DeathRecord.find(params[:death_record_id]).creator_role]
  end

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params(step)
    params.require(:death_record).permit(:first_name,
                                         :middle_name,
                                         :last_name,
                                         :suffixes,
                                         :first_name_aka,
                                         :middle_name_aka,
                                         :last_name_aka,
                                         :suffixes_aka,
                                         :social_security_number,
                                         :state,
                                         :county,
                                         :city,
                                         :zip_code,
                                         :street_and_number,
                                         :apt,
                                         :inside_city_limits,
                                         :spouse_first_name,
                                         :spouse_middle_name,
                                         :spouse_last_name,
                                         :spouse_suffixes,
                                         :father_first_name,
                                         :father_middle_name,
                                         :father_last_name,
                                         :father_suffixes,
                                         :mother_first_name,
                                         :mother_middle_name,
                                         :mother_last_name,
                                         :mother_suffixes,
                                         :sex,
                                         :date_of_birth,
                                         :birthplace_country,
                                         :birthplace_state,
                                         :birthplace_city,
                                         :hispanic_origin_explain,
                                         :race_explain,
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
                                         :place_of_disposition_city,
                                         :informants_suffixes,
                                         :informants_mailing_address_county,
                                         :informants_mailing_address_city,
                                         :informants_mailing_address_zip_code,
                                         :informants_mailing_address_street_and_number,
                                         :informants_mailing_address_apt,
                                         :method_of_disposition,
                                         :method_of_disposition_specified,
                                         :place_of_disposition,
                                         :place_of_disposition_state,
                                         :funeral_facility_name,
                                         :funeral_facility_state,
                                         :funeral_facility_county,
                                         :funeral_facility_city,
                                         :funeral_facility_zip_code,
                                         :funeral_facility_street_and_number,
                                         :funeral_director_license_number,
                                         :informants_name_first,
                                         :informants_name_middle,
                                         :informants_name_last,
                                         :informants_mailing_address_state,
                                         :owner_id,
                                         :place_of_death_type,
                                         :place_of_death_type_specific,
                                         :place_of_death_facility_name,
                                         :place_of_death_state,
                                         :place_of_death_county,
                                         :place_of_death_city,
                                         :place_of_death_zip_code,
                                         :place_of_death_street_and_number,
                                         :place_of_death_apt,
                                         :cause_of_death_attributes,
                                         :medical_certifier_county,
                                         :medical_certifier_city,
                                         :medical_certifier_zip_code,
                                         :medical_certifier_street_and_number,
                                         :medical_certifier_apt,
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
                                         :cause_of_death_attributes,
                                         :cause,
                                         :interval_to_death,
                                         :did_tobacco_use_contribute_to_death,
                                         :pregnancy_status,
                                         :manner_of_death,
                                         :medical_certifier_first,
                                         :medical_certifier_middle,
                                         :medical_certifier_last,
                                         :medical_certifier_suffix,
                                         :medical_certifier_state,
                                         :medical_certifier_license_number,
                                         :certifier_type,
                                         :date_certified).merge(form_step: step)
  end
end
