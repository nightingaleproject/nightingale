require 'test_helper'

class CityTest < ActiveSupport::TestCase
  test 'valid cities exist' do
    assert true, City.where(name: 'Amityville').count > 0
    assert true, City.where(name: 'Deer Grove').count > 0
    assert true, City.where(name: 'Aguila').count > 0
    assert true, City.where(name: 'Youngtown').count > 0
    assert true, City.where(name: 'Pepeekeo').count > 0
  end

  test 'cities in correct county' do
    correct = false
    City.where(name: 'Billerica').each do |city|
      correct = city.county.name == 'MIDDLESEX'
      break if correct
    end
    assert correct
    correct = false
    City.where(name: 'Boston').each do |city|
      correct = city.county.name == 'SUFFOLK'
      break if correct
    end
    assert correct
  end

  test 'cities in correct state' do
    correct = false
    City.where(name: 'Manchester').each do |city|
      correct = city.state.name == 'New Hampshire'
      break if correct
    end
    assert correct
    correct = false
    City.where(name: 'Atlanta').each do |city|
      correct = city.state.name == 'Georgia'
      break if correct
    end
    assert correct
  end

  test 'cities have correct zipcodes' do
    correct = false
    City.where(name: 'Manchester').each do |city|
      correct = city.zipcodes.where(name: '03103').count > 0
      break if correct
    end
    assert correct
    correct = false
    City.where(name: 'Billerica').each do |city|
      correct = city.zipcodes.where(name: '01821').count > 0
      break if correct
    end
    assert correct
  end
end
