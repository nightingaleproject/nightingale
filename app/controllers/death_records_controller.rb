# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :set_death_record, only: [:show, :destroy, :update]

  def index
    @death_records = policy_scope(DeathRecord)
  end

  def show
    # TODO: if not logged in, redirect to login.
    @questions_answers = {}
    answers = Answer::Answer.where(death_record_id: @death_record.id).to_a
    answers.each do |answer|
      @questions_answers[answer.question] = answer.answer
    end
  end

  def destroy
    # Authorization in death_record_policy.rb destroy function.
    authorize DeathRecord
    @death_record.destroy unless @death_record.nil?
    redirect_to root_path
  end

  def create
    # Authorization in death_record_policy.rb create function.
    authorize DeathRecord
    @death_record = DeathRecord.new
    @death_record.owner_id = current_user[:id]
    # A user can have multiple roles. For now we are assuming a user will have one role.
    @death_record.creator_role = current_user.roles[0].name
    # Grab the first step for the given record based on the user's role (Step list can be found in /config/steps/steps_config.yml)
    @death_record.record_status = APP_CONFIG[@death_record.creator_role][0]
    @death_record.save(validate: false)
    redirect_to death_record_step_path(@death_record, @death_record.record_status)
  end

  def update
    # Authorization in death_record_policy.rb update function.
    authorize DeathRecord
    # TODO: Look into Time.now.getLocal
    time_registered = Time.now.getlocal
    registered_by_id = current_user.id
    max_cert = DeathRecord.maximum('certificate_number')
    # starting certificate numbers at 10000 for now
    # TODO:  Confirm starting number and/or (likely) put this in a config file somewhere
    # TODO:  NOT ATOMIC
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
end
