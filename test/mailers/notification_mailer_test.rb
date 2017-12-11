require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @dr = DeathRecord.find(1)
    @user = User.find_by(email: 'doc1@example.com')
  end

  test 'notification email' do
    email = NotificationMailer.notification_email(@user, @dr, []).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [@user.email], email.to
    assert_equal 'Nightingale Notification', email.subject
  end
end