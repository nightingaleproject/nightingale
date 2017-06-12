class StepHistory < ApplicationRecord
  audited
  belongs_to :step
  belongs_to :death_record
  belongs_to :user
end
