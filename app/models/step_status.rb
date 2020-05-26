class StepStatus < ApplicationRecord
  audited
  belongs_to :death_record
  belongs_to :current_step, class_name: 'Step'
  belongs_to :next_step, class_name: 'Step', required: false
  belongs_to :previous_step, class_name: 'Step', required: false
  belongs_to :requestor, class_name: 'User', required: false

  # Update this StepStatus to mirror the given StepFlow.
  def mirror_step_flow(step_flow)
    self.current_step = step_flow.current_step
    self.next_step = step_flow.next_step
    self.previous_step = step_flow.previous_step
  end

  def as_json(options = {})
    {
      id: self.id,
      currentStep: current_step.as_json(options.merge({death_record: self.death_record})),
      nextStep: next_step.nil? ? nil : next_step.as_json(options.merge({death_record: self.death_record})),
      previousStep: previous_step.nil? ? nil : previous_step.as_json(options.merge({death_record: self.death_record}))
    }
  end
end
