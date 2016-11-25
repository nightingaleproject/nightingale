require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    assert_equal 0, User.count
    @user = User.create!(email: 'test@test.com', password: 'Password123!')
  end

  test 'confirmed' do
    assert_equal false, @user.confirmed?
    @user.confirm
    assert_equal true, @user.confirmed?
  end

  test 'grant and revoke admin' do
    assert_equal false, @user.admin?
    @user.grant_admin
    assert_equal true, @user.admin?
    @user.revoke_admin
    assert_equal false, @user.admin?
  end
end
