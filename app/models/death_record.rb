# Death Record model
class DeathRecord < ApplicationRecord
  has_one :decedent
  has_many :cause_of_death, -> { order(position: :asc) }
  accepts_nested_attributes_for :cause_of_death
end
