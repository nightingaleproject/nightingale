class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  steps *DeathRecord.form_steps

  def show
    @death_record = DeathRecord.find(params[:death_record_id])
    render_wizard
  end

  def update
    @death_record = DeathRecord.find(params[:death_record_id])
    @death_record.update(death_record_params(step))
    render_wizard @death_record
  end

  private
  
  # Never trust parameters from the internet, only allow the white list through.
  # TODO
  def death_record_params(step)
    params.require(:death_record).permit!.merge(form_step: step)
  end
end
