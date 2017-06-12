# Guest Helper module
module GuestHelper
  # Generate a new user with no password but with a token. If a user already
  # exists with that email, return the existing user.
  def self.generate_user(email, first_name, last_name, telephone, role)
    user = User.find_by(email: email)
    unless user.present?
      user = User.new(email: email, password: '', first_name: first_name, last_name: last_name, telephone: telephone)
      user.is_guest_user = true
      user.add_role role
      user.save(validate: false)
    end
    user
  end

  # Check if the given email is a valid account and that account is a guest
  # account.
  def self.guest_user_exists?(email)
    user = User.find_by(email: email)
    return true if user.present? && user.is_guest_user
    false
  end

  # Creates a unique token associated with the user and death record.
  # Valid currently for 3 days.
  def self.generate_user_token(user, death_record)
    @guest_token = UserToken.new(user: user, death_record: death_record)
    @guest_token.new_token!
    @guest_token.save
    @guest_token
  end

  # Generates the unique login link that is sent out in the email.
  def self.generate_login_link(user_token, root_url)
    root_url + "guest_users/#{user_token.token}"
  end

  # Sends the Guest User email out
  def self.send_login_link(guest_user, login_link)
    GuestMailer.guest_user_email(guest_user, login_link).deliver_later
  end
end
