# CauseOfDeath model
class CauseOfDeath < ApplicationRecord
  audited
  acts_as_list
  belongs_to :death_record
end
