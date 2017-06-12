# Rake tasks for setting up geographic data for Nightingale.
namespace :nightingale do
  namespace :geography do
    desc %(Generates YML fixtures containing U.S. geographic information.

    Specifically, this will generate fixtures for the following models:

    States->Counties->Cities->Zipcodes

    $ rake nightingale:geography:generate_fixtures)
    task generate_fixtures: :environment do
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
      parsed_geo_data = {}
      url_data = open(url_all).read
      csv = CSV.parse(url_data, headers: false)
      csv.drop(1).each do |row|
        state = abbreviations[row[2]]
        county = row[3]
        city = row[1]
        zip = row[0]
        parsed_geo_data[state] = {} if parsed_geo_data[state].nil? # State
        parsed_geo_data[state][county] = {} if parsed_geo_data[state][county].nil? # County
        parsed_geo_data[state][county][city] = [] if parsed_geo_data[state][county][city].nil? # City
        parsed_geo_data[state][county][city].push(zip.to_s) # Zip
      end

      # Generate fixtures from geographical information
      states = {}
      counties = {}
      cities = {}
      zipcodes = {}
      county_index_all = 0
      city_index_all = 0
      zipcode_index_all = 0
      parsed_geo_data.each_with_index do |(state, state_data), state_index|
        states[state] = {
          id: state_index,
          name: state,
          abbrv: abbreviations.key(state)
        }.stringify_keys!
        state_data.each do |county, county_data|
          counties[county + state] = {
            id: county_index_all,
            name: county,
            state_id: state_index
          }.stringify_keys!
          county_data.each do |city, city_data|
            cities[city + county + state] = {
              id: city_index_all,
              name: city,
              state_id: state_index,
              county_id: county_index_all
            }.stringify_keys!
            city_data.each do |zipcode|
              zipcodes[zipcode + city + county + state] = {
                id: zipcode_index_all,
                name: zipcode,
                state_id: state_index,
                county_id: county_index_all,
                city_id: city_index_all
              }.stringify_keys!
              zipcode_index_all += 1
            end
            city_index_all += 1
          end
          county_index_all += 1
        end
      end

      # Ensure omap YAML type (ensures order when loading)
      states = "--- !omap\n" + states.to_yaml.lines.to_a[1..-1].join
      counties = "--- !omap\n" + counties.to_yaml.lines.to_a[1..-1].join
      cities = "--- !omap\n" + cities.to_yaml.lines.to_a[1..-1].join
      zipcodes = "--- !omap\n" + zipcodes.to_yaml.lines.to_a[1..-1].join

      # Write results to fixture files
      open('test/fixtures/states.yml', 'w') { |f| f << states }
      open('test/fixtures/counties.yml', 'w') { |f| f << counties }
      open('test/fixtures/cities.yml', 'w') { |f| f << cities }
      open('test/fixtures/zipcodes.yml', 'w') { |f| f << zipcodes }
    end

    desc %(Loads YML fixture files containing U.S. geographic information
    into models useable by nightingale.

    This rake task expects these YML fixtures to be in the form as created by
    the geo:generate_geo_fixtures rake task, and to be located under the
    <ROOT DIRECTORY>/data directory.

    Fixture files are located at:
      - test/fixtures/states.yml
      - test/fixtures/counties.yml
      - test/fixtures/cities.yml
      - test/fixtures/zipcodes.yml

    $ rake nightingale:geography:load_fixtures)
    task load_fixtures: :environment do
      print 'Loading geographical data... '
      ENV['FIXTURES'] = 'states,counties,cities,zipcodes'
      Rake::Task['db:fixtures:load'].invoke
      puts 'Done!'
    end
  end
end
