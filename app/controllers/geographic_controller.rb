# Geographic Controller
class GeographicController < ApplicationController
  before_action :authenticate_user!

  def counties
    render json: GeoHelper.get_counties(params[:state])
  end

  def cities
    if params[:county].nil?
      render json: GeoHelper.get_cities_in_state(params[:state])
    else
      render json: GeoHelper.get_cities(params[:state], params[:county])
    end
  end

  def zipcodes
    render json: GeoHelper.get_zipcodes(params[:state], params[:county], params[:city])
  end
end
