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
    if record.death_record_flow.requested_edits && record.death_record_flow.skip_normal_workflow
      all_steps = all_steps_for_given_role_permission(User.find(record.owner_id).roles.first, record)
      index_of_current_step = all_steps.index(record.death_record_flow.current_step.name)
      unless index_of_current_step.nil?
        index_of_next_step = index_of_current_step + 1
        # If index is nil -> point to "next_step"
        if index_of_next_step > all_steps.index(all_steps.last)
          record.death_record_flow.current_step = record.death_record_flow.next_step
          record.death_record_flow.next_step = nil
        else
          record.death_record_flow.current_step = Step.where(name: all_steps[index_of_next_step]).first
        end
      end
    else
      unless record.death_record_flow.next_step.nil?
        record.death_record_flow.current_step = record.death_record_flow.next_step
        # Do a check to see if there is a "next_step" or if its the end
        step = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow.id, current_step_id: record.death_record_flow.next_step.id).first
        record.death_record_flow.next_step = step.nil? ? nil : step.next_step
      end
    end
    record.death_record_flow
  end

  # Given a step name and record, see if it comes before the records current step
  def self.step_come_before_current_step?(step, record)
    current_step = record.death_record_flow.current_step.name
    all_steps_for_record = all_steps_for_given_record(record)
    return true if all_steps_for_record.index(step) < all_steps_for_record.index(current_step)
  end

  # Change either the current step or both the current and next steps to any valid steps in the system.
  # Accepts the death record and a hash of current_step: name, next_step: name
  def self.update_record_flow(record, skip_normal_workflow, options = {})
    # Set current step to passed in step. Set next step to what ever normally comes next
    if options.length == 1 && options.key?(:current_step)
      current_step = Step.where(name: options[:current_step]).first
      workflow_step_navigation = WorkflowStepNavigation.where(workflow_id: record.death_record_flow.workflow_id, current_step_id: current_step.id).first
      next_step = Step.find(workflow_step_navigation.next_step_id)
      record.death_record_flow.current_step = current_step
      record.death_record_flow.next_step = next_step
    # Set the current and the next steps to whatever is passed in by the user.
    elsif options.length > 1 && options.key?(:current_step) && options.key?(:next_step)
      current_step = Step.where(name: options[:current_step]).first
      next_step = Step.where(name: options[:next_step]).first
      record.death_record_flow.current_step = current_step
      record.death_record_flow.next_step = next_step
      record.death_record_flow.skip_normal_workflow = skip_normal_workflow
    end
    record.death_record_flow.requested_edits = true
    record.death_record_flow.save!
    record
  end

  def self.first_step_for_given_role_permission(role, death_record)
    all_steps = all_steps_for_given_role_permission(role, death_record)
    all_steps.first
  end

  def self.last_step_for_given_role_permission(role, death_record)
    all_steps = all_steps_for_given_role_permission(role, death_record)
    all_steps.last
  end

  def self.all_steps_for_given_role_permission(role, death_record)
    # List of all steps in order from start to finish
    record_steps = all_steps_for_given_record(death_record)

    all_steps_permitted_by_role = []
    # Grab an array of step names that are permitted by the current user's role.
    all_steps_permitted = StepRolePermission.where(role_id: role.id)
    all_steps_permitted.each do |step_permission|
      all_steps_permitted_by_role << step_permission.step.name
    end

    # TODO: What will we return if there is no overlap?
    all_steps = []
    record_steps.each do |possible_step|
      all_steps << possible_step if all_steps_permitted_by_role.include?(possible_step) && !possible_step.start_with?('send')
    end

    all_steps
  end
end
