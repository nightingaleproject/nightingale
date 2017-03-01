###############################################################################
# Record creation for geographic data used for structured data input
###############################################################################
require 'yaml'
data = YAML.load_file('data/states_counties_cities_zips.yml')
data.each do |state, counties|
  state_obj = State.new(name: state)
  state_obj.save!
  counties.each do |county, cities|
    county_obj = state_obj.counties.create(name: county)
    county_obj.save!
    cities.each do |city, zipcodes|
      city_obj = county_obj.cities.create(name: city)
      city_obj.state_id = state_obj.id
      city_obj.save!
      zipcodes.each do |zipcode|
        zipcode_obj = city_obj.zipcodes.create(name: zipcode)
        zipcode_obj.save!
      end
    end
  end
end

###############################################################################
# Record creation for funeral facility data
###############################################################################
require 'yaml'
data = YAML.load_file('data/funeral_directors.yml')
data.each do |fd, fd_info|
  fd_obj = FuneralDirector.new(name: fd,
                               street_and_number: fd_info['street_and_number'],
                               city: fd_info['city'],
                               county: fd_info['county'],
                               state: fd_info['state'],
                               zip_code: fd_info['zip_code'])
  fd_obj.save!
end
