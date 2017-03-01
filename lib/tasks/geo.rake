namespace :geo do
  desc %(Generates a YML file containing U.S. geographic information.

  Specifically, it contains: States->Counties->Cities->Zipcodes

  The purpose of this file is to seed the database for geographic
  information used during the workflow (see rake geo:load_geo_yml)

  $ rake geo:generate_geo_yml OUTPUT=###)
  task generate_geo_yml: :environment do
    # Source of States, Counties, Cities, and Zips
    url_all = 'https://raw.githubusercontent.com/midwire/free_zipcode_data/master/all_us_zipcodes.csv'
    # Source of State abbreviations
    url_states = 'https://raw.githubusercontent.com/midwire/free_zipcode_data/master/all_us_states.csv'

    require 'open-uri'
    require 'csv'
    require 'yaml'

    # Open CSV source of State abbreviations
    abbreviations = {}
    url_data = open(url_states).read
    csv = CSV.parse(url_data, headers: false)
    csv.drop(1).each do |row|
      abbreviations[row[0]] = row[1]
    end

    # Open CSV source of all info and parse to nested hash
    output = {}
    url_data = open(url_all).read
    csv = CSV.parse(url_data, headers: false)
    csv.drop(1).each do |row|
      state = abbreviations[row[2]]
      county = row[3]
      city = row[1]
      zip = row[0]
      output[state] = {} if output[state].nil? # State
      output[state][county] = {} if output[state][county].nil? # County
      output[state][county][city] = [] if output[state][county][city].nil? # City
      output[state][county][city].push(zip.to_s) # Zip
    end

    # Write to file
    open(ENV['OUTPUT'], 'w') { |f| f << output.to_yaml }
  end

  desc %(Loads the given YML file containing U.S. geographic information
  into models useable by the edrs application.

  This YML file is expected to be in the structure that geo:generate_geo_yml
  creates (States->Counties->Cities->Zipcodes).

  NOTE: This should not normally have to be done manually! The seeds.rb
  does this itself on rake db:setup!

  $ rake geo:load_geo_yml INPUT=###)
  task load_geo_yml: :environment do
    require 'yaml'

    # Load YML file
    data = YAML.load_file(ENV['INPUT'])

    # Parse into database models
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
  end

  desc %(Loads the given YML file containing funeral director information.

  An example file is located at data/funeral_facilities.yml

  $ rake geo:load_fd_yml INPUT=###)
  task load_fd_yml: :environment do
    require 'yaml'

    # Load YML file
    data = YAML.load_file(ENV['INPUT'])

    data.each do |fd, fd_info|
      fd_obj = FuneralFacility.new(name: fd,
                                   street_and_number: fd_info['street_and_number'],
                                   city: fd_info['city'],
                                   county: fd_info['county'],
                                   state: fd_info['state'],
                                   zip_code: fd_info['zip_code'])
      fd_obj.save!
    end
  end
end
