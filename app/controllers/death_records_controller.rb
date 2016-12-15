# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :authenticate_user!, :set_death_record, only: [:show, :destroy, :update]

  def index
    @death_records = DeathRecordsPolicy::Scope.new(current_user, DeathRecord).resolve
  end

  def show
    #TODO if not logged in, redirect to login. 
  end

  def destroy
    @death_record.destroy unless @death_record.nil?
    redirect_to root_path
  end

  def create
    @death_record = DeathRecord.new
    @death_record.user_id = current_user[:id]
    @death_record.record_status = DeathRecord.form_steps.first
    @death_record.save(validate: false)
    redirect_to death_record_step_path(@death_record, DeathRecord.form_steps.first)
  end

  def update
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
  # TODO
  def death_record_params
    params.require(:death_record).permit!
  end
end
