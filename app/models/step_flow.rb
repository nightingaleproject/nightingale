class StepFlow < ApplicationRecord
  belongs_to :workflow
  belongs_to :current_step, class_name: 'Step', foreign_key: 'current_step_id'
  belongs_to :next_step, class_name: 'Step', foreign_key: 'next_step_id', required: false
  belongs_to :previous_step, class_name: 'Step', foreign_key: 'previous_step_id', required: false
  has_many :death_records
  default_scope { order(transition_order: :asc) }

  def next
    index = workflow.step_flows.index(self)
    workflow.step_flows[index + 1]
  end

  def prev
    index = workflow.step_flows.index(self)
    workflow.step_flows[index - 1]
  end
end
