# Comment Model
class Comment < ApplicationRecord
  audited
  belongs_to :death_record
  belongs_to :user

  validates :content, presence: true
  validates :user_id, presence: true
  validates :death_record_id, presence: true
end