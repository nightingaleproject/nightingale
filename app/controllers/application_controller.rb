# Application Controller
class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:danger] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :telephone, :email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :telephone, :email])
  end
end
