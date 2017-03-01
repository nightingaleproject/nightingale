# Geography helper module; used for structured data (geographical based)
module GeoHelper
  def self.get_states
    states = []
    State.all.each do |state|
      states.push(state.name)
    end
    states.sort_by!{ |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_counties(state)
    state_obj = State.find_by name: state
    counties = []
    state_obj.counties.each do |county|
      counties.push(county.name)
    end
    counties.sort_by!{ |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities(state, county)
    state_obj = State.find_by name: state
    county_obj = state_obj.counties.find_by name: county
    cities = []
    county_obj.cities.each do |city|
      cities.push(city.name)
    end
    cities.sort_by!{ |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_cities_in_state(state)
    state_obj = State.find_by name: state
    cities = []
    state_obj.cities.each do |city|
      cities.push(city.name)
    end
    cities.sort_by!{ |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end

  def self.get_zipcodes(state, county, city)
    state_obj = State.find_by name: state
    county_obj = state_obj.counties.find_by name: county
    city_obj = county_obj.cities.find_by name: city
    zipcodes = []
    city_obj.zipcodes.each do |zipcode|
      zipcodes.push(zipcode.name)
    end
    zipcodes.sort_by!{ |e| ActiveSupport::Inflector.transliterate(e.downcase) }
  end
end
