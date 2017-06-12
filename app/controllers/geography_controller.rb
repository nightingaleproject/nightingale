# Geography Controller
class GeographyController < ApplicationController
  before_action :authenticate_user!

  # Build a hash of options for geographical forms based on the parameters
  # given. For example, if we only receive a state name, we will return the
  # list of all possible states as well as all counties in the given state.
  # If the 'next' parameter is true, only the required information will be
  # returned (the user selects a county, we now just want all of the cities
  # in that county).
  def geography_full
    if params[:geography].present? && geography_params[:next]
      name, options = fill_next_full
      result = {};
      result[name] = options
      render json: result
      return
    end
    states = GeographyHelper.get_states
    # Don't proceed if there is no existing state (probably a new death record)
    if params[:geography].present?
      if geography_params[:state]
        counties = GeographyHelper.get_counties(geography_params[:state])
      end
      if geography_params[:state] && geography_params[:county]
        cities = GeographyHelper.get_cities(geography_params[:state], geography_params[:county])
      end
      if geography_params[:state] && geography_params[:county] && geography_params[:city]
        zipcodes = GeographyHelper.get_zipcodes(geography_params[:state], geography_params[:county], geography_params[:city])
      end
    end
    render json: {
      state: states ? states : [],
      county: counties ? counties : [],
      city: cities ? cities : [],
      zip: zipcodes ? zipcodes : []
    }
  end

  # Similar to geography_full, except only gathers country, state, and city
  # data.
  def geography_short
    # TODO: something is wrong with this
    if params[:geography].present? && geography_params[:next]
      name, options = fill_next_short
      result = {};
      result[name] = options
      render json: result
      return
    end
    if params[:geography].present?
      if geography_params[:country]
        states = GeographyHelper.get_cities_in_state(geography_params[:state])
      end
    end
    # Don't proceed if there is no existing state (probably a new death record)
    if params[:geography].present?
      if geography_params[:state]
        cities = GeographyHelper.get_cities_in_state(geography_params[:state])
      end
    end
    render json: {
      state: states ? states : [],
      city: cities ? cities : []
    }
  end

  private

  # Returns the next logical grouping of data. For example, if given a state
  # and a county, return the cities in that county.
  def fill_next_full
    return ['state', GeographyHelper.get_states] unless geography_params[:state].present?
    return ['county', GeographyHelper.get_counties(geography_params[:state])] unless geography_params[:county].present?
    return ['city', GeographyHelper.get_cities(geography_params[:state], geography_params[:county])] unless geography_params[:city].present?
    return ['zip', GeographyHelper.get_zipcodes(geography_params[:state], geography_params[:county], geography_params[:city])] unless geography_params[:zipcode].present?
  end

  # Similar to fill_next_full, except only gathers country, state, and city
  # data.
  def fill_next_short
    return ['state', GeographyHelper.get_states] unless geography_params[:state].present?
    return ['city', GeographyHelper.get_cities_in_state(geography_params[:state])] unless geography_params[:city].present?
  end

  def geography_params
    params.require(:geography).permit(:next, :country, :state, :county, :city, :zip)
  end
end
