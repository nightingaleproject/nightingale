# Death Record model
class DeathRecord < ApplicationRecord
  after_save :check_owner_change
  has_many :cause_of_death, -> { order(position: :asc) }, dependent: :destroy
  has_many :comments
  accepts_nested_attributes_for :cause_of_death
  belongs_to :user
  audited
  has_one :user_token, dependent: :destroy
  has_one :death_record_flow, dependent: :destroy

  # Used for validating supplemental errors
  attr_accessor :supplemental_error_flag, :supplemental_error

  # If the "owner_id" is updated on the model update Death_Record_History with the new owner_id and death_record_id.
  def check_owner_change
    unless changes['owner_id'].nil?
      DeathRecordHistory.create!(death_record_id: id, user_id: changes['owner_id'][1])
    end
  end
end
