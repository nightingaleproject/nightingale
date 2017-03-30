# Guest Users Controller - Redirects to steps controller with the addition
# Of the user_token and death_record
class GuestUsersController < ApplicationController
  before_action :set_params, only: [:show]

  def show
    # Redirects to correct step with the correct death record.
    redirect_to death_record_step_path(@death_record, id: @death_record.death_record_flow.current_step.name, guest_user_id: @user_token.token)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_params
    @user_token = UserToken.where(token: params[:guest_user_token]).first
    @death_record = DeathRecord.find(@user_token.death_record_id)
  end
end
