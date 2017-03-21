# Steps Helper module
module StepsHelper
  # List primary steps; full names
  def self.steps
    ['identity', 'demographics', 'disposition', 'medical']
  end

  # List all steps; full names
  def self.all_steps
    ['identity', 'demographics', 'disposition', 'send_to_medical_professional', 'send_to_funeral_director', 'medical', 'send_to_registrar']
  end

  # List primary steps; shortened names
  def self.steps_short
    StepsHelper.steps.map { |s| s.truncate(5, omission: '.') }
  end

  def self.steps_for_role(role)
    if role == 'funeral_director'
      ['identity', 'demographics', 'disposition', 'send_to_medical_professional']
    elsif role == 'physician'
      ['medical', 'send_to_registrar']
    else
      []
    end
  end

  # Gets the status of a step given a death record
  # Possible results are:
  # 'done': the step has been completed
  # 'in progress': the step is in progress
  # 'not started': the step has not been started
  def self.step_status(target_step, death_record)
    workflow = APP_CONFIG[death_record.creator_role]
    workflow_record_step = workflow.index(death_record.record_status)
    workflow_target_step = workflow.index(target_step)
    return 'in progress' if death_record.record_status == target_step
    return 'done' if (death_record.record_status.include? 'finish') || workflow_record_step > workflow_target_step
    'not started'
  end
end