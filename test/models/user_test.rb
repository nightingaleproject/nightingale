require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: 'test@test.com', password: 'Password123!')
    @fd = User.find_by(email: 'fd1@example.com')
    @doc = User.find_by(email: 'doc1@example.com')
    @reg = User.find_by(email: 'reg1@example.com')
  end

  test 'registrar can register' do
    assert_equal true, @reg.registrar?
    assert_equal true, @reg.can_register_record?
  end

  test 'fd and doc can start record' do
    assert_equal true, @fd.can_start_record?
    assert_equal true, @doc.can_start_record?
  end

  test 'doc can request edits' do
    assert_equal true, @doc.can_request_edits?
  end

  test 'grant and revoke admin' do
    assert_equal false, @user.admin?
    @user.grant_admin
    assert_equal true, @user.admin?
    @user.revoke_admin
    assert_equal false, @user.admin?
  end
end
