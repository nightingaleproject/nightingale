# Workflow DB Helper module
module WorkflowHelper
  # Get first step for a workflow Given a role
  def self.first_step_based_on_role(role)
    workflow_steps = WorkflowStepNavigation.where(workflow_id: Workflow.where(name: role).first).order(transition_order: :asc)
    if workflow_steps.empty?
      ''
    else
      workflow_steps.first.current_step.name
    end
  end

  # Get the last step of a workflow Given a role.
  def self.last_step_based_on_role(role)
    workflow_steps = WorkflowStepNavigation.where(workflow_id: Workflow.where(name: role).first).order(transition_order: :asc)
    if workflow_steps.empty?
      ''
    else
      workflow_steps.last.next_step.name
    end
  end

  # Get the first step in a workflow given a record
  def self.first_step_based_on_record(record)
    workflow_steps = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow.id).order(transition_order: :asc)
    if workflow_steps.empty?
      ''
    else
      workflow_steps.first.current_step.name
    end
  end

  # Get the last step in a workflow given a record
  def self.last_step_based_on_record(record)
    workflow_steps = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow.id).order(transition_order: :asc)
    if workflow_steps.empty?
      ''
    else
      workflow_steps.last.next_step.name
    end
  end

  # Given a role get a list of all steps in order
  def self.all_steps_for_given_role(role)
    steps = []
    # Grab the workflow transitions for the given workflow and order them in ascending order based on transition id.
    workflow_steps = WorkflowStepNavigation.where(workflow_id: Workflow.where(name: role).first).order(transition_order: :asc)

    unless workflow_steps.empty?
      steps << workflow_steps.first.current_step.name # We want to grab the starting step before anything else
      workflow_steps.each do |step_navigation|
        steps << step_navigation.next_step.name # Add the rest of the steps in the workflow.
      end
    end
    steps
  end

  # Given a record get a list of all steps in order.
  def self.all_steps_for_given_record(record)
    steps = []
    # Grab the workflow transitions for the given workflow and order them in ascending order based on transition id.
    workflow_steps = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow.id).order(transition_order: :asc)

    unless workflow_steps.empty?
      steps << workflow_steps.first.current_step.name # We want to grab the starting step before anything else
      workflow_steps.each do |step_navigation|
        steps << step_navigation.next_step.name # Add the rest of the steps in the workflow.
      end
    end
    steps
  end

  # Given a record get the next step
  def self.grab_next_step(record)
    record.death_record_flow.next_step.name
  end

  # Given a record, update the step transition to the next step
  def self.next_step(record)
    # TODO: This will need to be updated to check for (update_record_flow) issues.
    unless record.death_record_flow.next_step.nil?
      record.death_record_flow.current_step = record.death_record_flow.next_step
      # Do a check to see if there is a "next_step" or if its the end
      step = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow.id, current_step_id: record.death_record_flow.next_step.id).first
      record.death_record_flow.next_step = step.nil? ? nil : step.next_step
    end
    record.death_record_flow
  end

  # Given a step name and record, see if it comes before the records current step
  def self.step_come_before_current_step?(step, record)
    current_step = record.death_record_flow.current_step.name
    all_steps_for_record = all_steps_for_given_record(record)
    return true if all_steps_for_record.index(step) < all_steps_for_record.index(current_step)
  end
end
