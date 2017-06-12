# Comment Model
class Comment < ApplicationRecord
  audited
  belongs_to :death_record
  belongs_to :user

  def as_json(options = {})
    {
      id: self.id,
      content: self.content,
      author: self.user.as_json(options),
      createdAt: self.created_at
    }
  end
end
