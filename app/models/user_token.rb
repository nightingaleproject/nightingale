# User Token model
class UserToken < ApplicationRecord
  belongs_to :user
  belongs_to :death_record

  def new_token!
    SecureRandom.hex(32).tap do |random_token|
      self.token = random_token
      self.token_generated_at = Time.now.utc
    end
  end

  def login_token_expired?
    # Does the token exist anymore?
    if self.is_expired
      return true
    end
    # Has the token expired?
    if Time.now.utc > (self.token_generated_at + token_validity)
      expire_token!
      return true
    end

    return false
  end

  def expire_token!
    self.is_expired = true
    save!
  end

  private

  def token_validity
    3.days
  end
end