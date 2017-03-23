# Steps Helper module
module StepsHelper
  # List primary steps; full names
  def self.steps
    StepsHelper.all_steps.select { |step| !(step.starts_with? 'send') }
  end

  # List all steps; full names
  def self.all_steps
    Step.all.pluck(:name)
  end

  # List primary steps; shortened names
  def self.steps_short
    StepsHelper.steps.map { |s| s.truncate(5, omission: '.') }
  end

  # TODO: This will need to be changed to consider the fact steps are based on the role of the death_record creator.
  # Meaning, a physician could have the step 'send_to_funeral_director' or a funeral director could have 'send_to_registrar'
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
    workflow = WorkflowHelper.all_steps_for_given_record(death_record)
    workflow_record_step = workflow.index(death_record.death_record_flow.current_step.name)
    workflow_target_step = workflow.index(target_step)
    return 'in progress' if death_record.death_record_flow.current_step.name == target_step
    return 'done' if (death_record.death_record_flow.current_step.name.include? 'finish') || workflow_record_step > workflow_target_step
    'not started'
  end
end
