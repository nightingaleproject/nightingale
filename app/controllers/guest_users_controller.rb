# Guest Users Controller
class GuestUsersController < ApplicationController
  before_action :set_params, only: [:show]

  def show
    redirect_to edit_death_record_path(@user_token.death_record_id)
  end

  private

  def set_params
    @user_token = UserToken.find_by(token: params[:guest_user_token])
  end
end
