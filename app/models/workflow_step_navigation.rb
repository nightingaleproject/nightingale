# Work flow step navigation model. Detailing the next step in a given workflow
class WorkflowStepNavigation < ApplicationRecord
  audited
  belongs_to :workflow
  belongs_to :current_step, class_name: "Step", foreign_key: :current_step_id
  belongs_to :next_step, class_name: "Step", foreign_key: :next_step_id
end
