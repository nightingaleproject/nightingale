# Death record flow model. Contains information for a given death record.
class DeathRecordFlow < ApplicationRecord
  audited
  belongs_to :death_record
  belongs_to :workflow
  belongs_to :current_step, class_name: 'Step', foreign_key: :current_step_id
  belongs_to :next_step, class_name: 'Step', foreign_key: :next_step_id
end
