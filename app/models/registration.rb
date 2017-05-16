# Registration Model
class Registration < ApplicationRecord
  belongs_to :death_record

  def as_json(options = {})
    {
      id: self.id,
      registered: self.registered.strftime('%m/%d/%Y %H:%M %Z')
    }
  end
end
