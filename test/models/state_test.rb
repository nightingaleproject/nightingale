require 'test_helper'

class StateTest < ActiveSupport::TestCase
  test 'valid states exist' do
    assert true, State.where(name: 'New Hampshire').count > 0
    assert true, State.where(name: 'Massachusetts').count > 0
    assert true, State.where(name: 'Texas').count > 0
    assert true, State.where(name: 'Arizona').count > 0
    assert true, State.where(name: 'Rhode Island').count > 0
  end

  test 'states have correct counties' do
    assert State.where(name: 'New Hampshire').first.counties.where(name: 'HILLSBOROUGH').count > 0
    assert State.where(name: 'New York').first.counties.where(name: 'WESTCHESTER').count > 0
  end
end
