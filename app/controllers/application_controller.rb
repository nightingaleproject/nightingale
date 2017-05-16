class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :telephone, :email])
      devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :telephone, :email])
    end
end
