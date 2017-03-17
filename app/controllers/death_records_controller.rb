# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :set_death_record, only: [:show, :destroy, :update, :reenable]

  def index
    # Authorization in death_record_policy.rb index function (this is only to restrict guest_users)
    authorize DeathRecord
    # Shows only the records that the user owns. Admin can see all records.
    @death_records = policy_scope(DeathRecord).select { |record| record.time_registered.nil? && !record.voided }
    # Grab all records that have been voided
    @voided_death_records = voided_death_records
    # Grab all records touched by this user minus those that are active
    @transferred_death_records = transferred_death_records - @death_records - @voided_death_records
  end

  def show
    # Grab supplementary questions and their answers
    @questions_answers = {}
    Answer::Answer.where(death_record_id: @death_record.id).each do |answer|
      @questions_answers[answer.question] = answer.answer
    end
  end

  def destroy
    # Authorization in death_record_policy.rb destroy function.
    authorize DeathRecord
    # Do not delete any death records, only void them.
    @death_record.update_attribute('voided', true)
    @death_record.save(validate: false)
    redirect_to root_path
  end

  def reenable
    # Authorization in death_record_policy.rb destroy function.
    authorize DeathRecord
    # Reenable voided death record.
    @death_record.update_attribute('voided', false)
    @death_record.save(validate: false)
    redirect_to root_path
  end

  def create
    # Authorization in death_record_policy.rb create function.
    authorize DeathRecord
    @death_record = DeathRecord.new
    @death_record.owner_id = current_user.id
    @death_record.creator_id = current_user.id
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
    time_registered = Time.zone.now
    registered_by_id = current_user.id

    # Start ceritifcate number at 10000, and increment by death record id
    certificate_number = 9999 + @death_record.id

    unless @death_record.update_attributes(time_registered: time_registered,
                                           registered_by_id: registered_by_id,
                                           certificate_number: certificate_number,
                                           was_an_autopsy_performed: true,
                                           were_autopsy_findings_available: true)
      logger.debug(@death_record.errors.inspect)
    end

    redirect_to action: 'show', id: @death_record.id
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_death_record
    @death_record = DeathRecord.find(params[:id])
  end

  # Grab all records that at one point was touched by this user.
  def transferred_death_records
    historical_death_records = DeathRecordHistory.where(user_id: current_user.id)
    transferred_death_records = []
    if current_user.registrar?
      historical_death_records.each do |record|
        if DeathRecord.exists?(id: record.death_record_id) &&
           !DeathRecord.find(record.death_record_id).time_registered.nil?
          transferred_death_records << DeathRecord.find(record.death_record_id)
        end
      end
    else
      historical_death_records.each do |record|
        if DeathRecord.exists?(id: record.death_record_id)
          transferred_death_records << DeathRecord.find(record.death_record_id)
        end
      end
    end
    transferred_death_records
  end

  # Grab all records that have been voided.
  def voided_death_records
    return DeathRecord.where(voided: true) if current_user.admin?
    DeathRecord.where(creator_id: current_user.id, voided: true)
  end
end
