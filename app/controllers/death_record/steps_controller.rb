class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  steps *DeathRecord.form_steps

  def show
    @death_record = DeathRecord.find(params[:death_record_id])
    @users_with_medical_roles = User.with_any_role(:physician, :medical_examiner)
    render_wizard
  end

  def update
    @death_record = DeathRecord.find(params[:death_record_id])      
    if @death_record.update(death_record_params(step))
      unless step == 'medical' && !(current_user.has_role? :physician)
        @death_record.record_status = next_step
      end
    end
    render_wizard @death_record
  end

  private

  # Never trust parameters from the internet, only allow the white list through.
  # TODO
  def death_record_params(step)
    params.require(:death_record).permit!.merge(form_step: step)
  end
end
