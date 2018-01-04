require 'test_helper'

class GuesteHelperTest < ActiveSupport::TestCase
  setup do
    @test_user = GuestHelper.generate_user('test@test.com', 'test', 'test', '123-456-7891', 'test')
    @death_record = DeathRecord.new(creator: @test_user,
                                      owner: @test_user)
  end

  test 'guest user exists' do
    assert_not_nil @test_user
  end

  test 'guest user already exists' do
    assert GuestHelper.guest_user_exists? 'test@test.com'
  end

  test 'generating user token' do
    user_token = GuestHelper.generate_user_token(@test_user, @death_record)
    assert_not_nil user_token
    assert_not_equal '', user_token
  end

  test 'generate login link' do
    user_token = GuestHelper.generate_user_token(@test_user, @death_record)
    login_link = GuestHelper.generate_login_link(user_token, 'test')
    assert_not_nil login_link
    assert_not_equal '', login_link
  end
end
