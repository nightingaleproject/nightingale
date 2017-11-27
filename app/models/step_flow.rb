class StepFlow < ApplicationRecord
  belongs_to :workflow
  belongs_to :current_step, class_name: 'Step', foreign_key: 'current_step_id'
  belongs_to :next_step, class_name: 'Step', foreign_key: 'next_step_id'
  belongs_to :previous_step, class_name: 'Step', foreign_key: 'previous_step_id'
  has_many :death_records
  default_scope { order(transition_order: :asc) }

  def next
    workflow.step_flows.where("id > ?", id).first
  end

  def prev
    workflow.step_flows.where("id < ?", id).last
  end
end
