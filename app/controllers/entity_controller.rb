class EntityController < ApplicationController

  before_filter :authenticate_user!

  def funeral_director_details
    render json: EntityHelper.get_funeral_director_details(params[:name])
  end

end
