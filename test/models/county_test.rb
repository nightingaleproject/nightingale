require 'test_helper'

class CountyTest < ActiveSupport::TestCase
  test 'valid counties exist' do
    assert true, City.where(name: 'MIDDLESEX').count > 0
    assert true, City.where(name: 'SUFFOLK').count > 0
    assert true, City.where(name: 'HILLSBOROUGH').count > 0
    assert true, City.where(name: 'WESTCHESTER').count > 0
    assert true, City.where(name: 'HAMILTON').count > 0
  end

  test 'counties in correct state' do
    correct = false
    County.where(name: 'HILLSBOROUGH').each do |county|
      correct = county.state.name == 'New Hampshire'
      break if correct
    end
    assert correct
    correct = false
    County.where(name: 'WESTCHESTER').each do |county|
      correct = county.state.name == 'New York'
      break if correct
    end
    assert correct
    correct = false
    County.where(name: 'WASHINGTON').each do |county|
      correct = county.state.name == 'Minnesota'
      break if correct
    end
    assert correct
    correct = false
    County.where(name: 'DUNKLIN').each do |county|
      correct = county.state.name == 'Missouri'
      break if correct
    end
    assert correct
  end

  test 'counties have correct cities' do
    correct = false
    County.where(name: 'HILLSBOROUGH').each do |county|
      correct = county.cities.where(name: 'Manchester').count > 0
      break if correct
    end
    assert correct
    correct = false
    County.where(name: 'WESTCHESTER').each do |county|
      correct = county.cities.where(name: 'Yonkers').count > 0
      break if correct
    end
    assert correct
  end
end
