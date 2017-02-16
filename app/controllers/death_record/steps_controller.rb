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

    # For now we will include comments at the bottom of the send page only.
    # TODO: This might need to change. Maybe we want it on all pages?
    if step.start_with? 'send'
      @comments = @death_record.comments
    end
    render_wizard
  end

  def update
    # Policy function update in step_policy.rb
    authorize :step, :update?
    @death_record = DeathRecord.find(params[:death_record_id])
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
        # Destroy any old versions of this answer
        Answer::Answer.where(death_record_id: @death_record.id, question_id: question.id).destroy_all
        # Create a new answer
        answer = Answer::Answer.new
        answer.answer = params['question' + question.id.to_s]
        answer.death_record_id = @death_record.id
        answer.question_id = question.id
        answer.question = question.question
        answer.save!
      end
    end
    if @error.nil? || !@error
      @death_record.supplemental_error_flag = false
    else
      @death_record.supplemental_error_flag = true
    end

    # Update the death record
    @death_record.update(death_record_params(step))

    # Special Case when transfering ownership from Funeral director to physician or ME or Registrar
    # Instead of directing to the next step screen, we send the user back to the home dashboard
    # becasue they no longer are owners of the death record
    if step.start_with? 'send'
      # TODO: Should we allow guest users to send the record to another guest user??!
      # Death record owner_id gets set in the view if they use the drop down.
      # This check confirms that they did not select a user from the drop down list.
      # Check if owner is guest user sending it to an existing user.
      if @death_record.owner_id.nil? && params[:owner_email] != ''
        @guest_user = generate_user(params[:owner_email], step)
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
  def generate_user (email, step)
    # TODO: What should the role be of the guest user?
    user = User.where(email: email).first
    if !user.present?
      user = User.new(email: email, password: '')
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

    return user
  end

  def generate_user_token (user_id, death_record_id)
    @guest_token = UserToken.new(user_id: user_id, death_record_id: death_record_id)
    @guest_token.new_token!
    @guest_token.save
    return @guest_token
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
    params.require(:death_record).merge(form_step: step).permit!
  end
end
