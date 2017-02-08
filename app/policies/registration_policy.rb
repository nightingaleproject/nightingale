# Headless Registration Policy (no model associated with this policy file) For Devise Edit User Page.
class RegistrationPolicy
  def initialize(user, registration)
    @user = user
  end

  def edit?
    !@user.is_guest_user
  end
end
