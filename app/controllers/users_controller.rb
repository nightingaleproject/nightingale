class UsersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :verify_is_admin

  # GET /users
  def index
    @users = User.all
  end

  def become
    return unless current_user.admin?
    sign_in(:user, User.find(params[:id]))
    redirect_to root_url
  end

  def delete
    return unless current_user.admin?
    User.delete(params[:id])
    redirect_to users_path
  end

  private

  def verify_is_admin
    (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end

end
