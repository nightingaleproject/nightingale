# Admins Controller
class AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_is_admin

  def index
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
