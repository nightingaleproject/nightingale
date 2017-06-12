# app/controllers/registrations_controller.rb
class PasswordsController < Devise::PasswordsController
  protected

  # If the user resetting their password is a guest user, change the
  # is_guest_user flag to false.
  def after_resetting_password_path_for(resource)
    if resource.is_guest_user
      resource.is_guest_user = false
      resource.save!
    end
    super
  end
end
