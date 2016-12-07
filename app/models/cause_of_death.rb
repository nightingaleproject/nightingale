# CauseOfDeath model
class CauseOfDeath < ApplicationRecord
  acts_as_list
  belongs_to :death_record
end
