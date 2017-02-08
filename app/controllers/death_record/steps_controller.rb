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
      redirect_to root_path
      return
    end
    render_wizard @death_record
  end

  private

  # Set the steps for the multipage form from the steps set on the death record model
  def set_steps
    self.steps = APP_CONFIG[DeathRecord.find(params[:death_record_id]).creator_role]
  end

  # Never trust parameters from the internet, only allow the white list through.
  def death_record_params(step)
    params.require(:death_record).merge(form_step: step).permit!
  end
end
