require 'test_helper'

class ZipcodeTest < ActiveSupport::TestCase
  test 'valid zipcodes exist' do
    assert true, Geography::Zipcode.where(name: '03045').count > 0
    assert true, Geography::Zipcode.where(name: '01821').count > 0
    assert true, Geography::Zipcode.where(name: '92113').count > 0
    assert true, Geography::Zipcode.where(name: '85250').count > 0
    assert true, Geography::Zipcode.where(name: '53001').count > 0
  end
end
