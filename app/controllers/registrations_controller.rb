# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  include Pundit

  # Add Pundit authorization to the edit function in User registration.
  def edit
    authorize :registration, :edit?
    super
  end
end