require 'test_helper'

class StateTest < ActiveSupport::TestCase
  test 'valid states exist' do
    assert true, Geography::State.where(name: 'New Hampshire').count > 0
    assert true, Geography::State.where(name: 'Massachusetts').count > 0
    assert true, Geography::State.where(name: 'Texas').count > 0
    assert true, Geography::State.where(name: 'Arizona').count > 0
    assert true, Geography::State.where(name: 'Rhode Island').count > 0
  end

  test 'states have correct counties' do
    assert Geography::State.where(name: 'New Hampshire').first.counties.where(name: 'HILLSBOROUGH').count > 0
    assert Geography::State.where(name: 'New York').first.counties.where(name: 'WESTCHESTER').count > 0
  end
end
