class Workflow < ApplicationRecord
  has_many :step_flows

  # Return the Steps for this workflow.
  def steps
    self.step_flows.includes(:current_step).collect(&:current_step)
  end
end
