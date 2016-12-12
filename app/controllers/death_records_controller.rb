# Death Records Controller
class DeathRecordsController < ApplicationController
  before_action :authenticate_user!, :set_death_record, only: [:show]

  def index
    @death_records = DeathRecordsPolicy::Scope.new(current_user, DeathRecord).resolve  
  end

  def show
  end

  def create
    @death_record = DeathRecord.new
    @death_record.user_id = current_user[:id]
    @death_record.save(validate: false)
    redirect_to death_record_step_path(@death_record, DeathRecord.form_steps.first)
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
