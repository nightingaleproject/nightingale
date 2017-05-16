# Geography Helper module
module GeographyHelper
  def self.get_states
    states = State.pluck(:name)
    states = [] unless states
    states.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_counties(state)
    state_obj = State.find_by(name: state)
    counties = County.where(state: state_obj).pluck(:name) if state_obj
    counties = [] unless counties
    counties.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities(state, county)
    state_obj = State.find_by(name: state)
    county_obj = state_obj.counties.find_by(name: county) if state_obj
    cities = City.where(state: state_obj, county: county_obj).pluck(:name) if county_obj
    cities = [] unless cities
    cities.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities_in_state(state)
    state_obj = State.find_by(name: state)
    cities = City.where(state: state_obj).pluck(:name) if state_obj
    cities = [] unless cities
    cities.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_zipcodes(state, county, city)
    state_obj = State.find_by(name: state)
    county_obj = state_obj.counties.find_by(name: county) if state_obj
    city_obj = county_obj.cities.find_by(name: city) if county_obj
    zipcodes = Zipcode.where(state: state_obj, county: county_obj, city: city_obj).pluck(:name)
    zipcodes = [] unless zipcodes
    zipcodes.sort_by! { |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end
end
