class DeathRecord::StepsController < ApplicationController
  include Wicked::Wizard
  steps *DeathRecord.form_steps

  def show
    authorize :step, :show?
    @death_record = DeathRecord.find(params[:death_record_id])
    case step.to_sym
    when :fd_to_me
      @users_with_medical_roles = User.with_any_role(:physician, :medical_examiner)
    when :medical
      @registrars = User.with_any_role(:registrar)
    end
    render_wizard
  end

  def update
    @death_record = DeathRecord.find(params[:death_record_id])
    @death_record.record_status = next_step
    @death_record.update(death_record_params(step))
    # Special Case when transfering ownership from Funeral director to physician or ME
    if step == 'fd_to_me'
      redirect_to root_path and return
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
