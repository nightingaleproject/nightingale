require 'test_helper'

class GeographyHelperTest < ActiveSupport::TestCase
  setup do
    @state = 'Massachusetts'
    @county = 'ESSEX'
    @city = 'Andover'
  end

  test 'get states' do
    assert_equal 51,  GeographyHelper.get_states.count
  end

  test 'get counties' do 
    assert_equal 14, GeographyHelper.get_counties(@state).count
  end

  test 'get cities' do
    assert_equal 39, GeographyHelper.get_cities(@state, @county).count
  end

  test 'get cities in state' do
    assert_equal 511, GeographyHelper.get_cities_in_state(@state).count
  end

  test 'get zipcodes' do
    assert_equal 5, GeographyHelper.get_zipcodes(@state, @county, @city).count
  end

end
