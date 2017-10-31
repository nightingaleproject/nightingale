require 'test_helper'

class NameHelperTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: 'test@test.com', password: 'Password123!', first_name: 'Bill', last_name: 'Smith')
  end

  test 'pretty printing of user' do
    assert_equal 'Smith, Bill', NameHelper.pretty_user_name(@user)
  end

  test 'pretty printing of name' do
    assert_equal 'Smith, Bill H.', NameHelper.pretty_name('Bill', 'H', 'Smith')
    assert_equal 'Bill', NameHelper.pretty_name('Bill', nil, nil)
    assert_equal 'Smith', NameHelper.pretty_name(nil, nil, 'Smith')
    assert_equal 'Bill H.', NameHelper.pretty_name('Bill', 'H', nil)
    assert_equal 'Smith H.', NameHelper.pretty_name(nil, 'H', 'Smith')
    assert_equal 'Smith, Bill', NameHelper.pretty_name('Bill', nil, 'Smith')    
  end
end
