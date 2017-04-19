# Guest User Helper module
module GuestUserHelper
  # Generates a new user with no password but with a token.
  # If a user already exists with that email, return the existing user.
  def self.generate_user(email, first_name, last_name, telephone, step)
    # TODO: What should the role be of the guest user?
    user = User.where(email: email).first
    unless user.present?
      user = User.new(email: email, password: '', first_name: first_name, last_name: last_name, telephone: telephone)
      user.is_guest_user = true
      user.skip_confirmation!

      # Assuming guest_user's role based on step.
      if step.to_sym == :send_to_medical_professional
        user.add_role 'physician' # :medical_examiner TODO: How do we determine if its physician or medical_examiner
      elsif step.to_sym == :send_to_funeral_director
        user.add_role 'funeral_director'
      end
      user.save(validate: false)
    end
    user
  end

  # Creates a unique token associated with the user and death record.
  # Valid currently for 3 days.
  def self.generate_user_token(user_id, death_record_id)
    @guest_token = UserToken.new(user_id: user_id, death_record_id: death_record_id)
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
