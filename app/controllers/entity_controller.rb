# Entity Controller
class EntityController < ApplicationController
  before_action :authenticate_user!

  def funeral_facility_details
    render json: EntityHelper.get_funeral_facility_details(params[:name])
  end
end
