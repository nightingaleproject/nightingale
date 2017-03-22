# Geography helper module; used for structured data (geographical based)
module GeoHelper
  def self.get_states
    states = State.pluck(:name)
    states.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_counties(state)
    state_obj = State.find_by name: state
    counties = County.where(state_id: state_obj.id).pluck(:name)
    counties.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities(state, county)
    state_obj = State.find_by name: state
    county_obj = state_obj.counties.find_by name: county
    cities = City.where(state_id: state_obj.id, county_id: county_obj.id).pluck(:name)
    cities.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities_in_state(state)
    state_obj = State.find_by name: state
    cities = City.where(state_id: state_obj.id).pluck(:name)
    cities.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_zipcodes(state, county, city)
    state_obj = State.find_by name: state
    county_obj = state_obj.counties.find_by name: county
    city_obj = county_obj.cities.find_by name: city
    zipcodes = Zipcode.where(state_id: state_obj.id, county_id: county_obj.id, city_id: city_obj.id).pluck(:name)
    zipcodes.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end
end
