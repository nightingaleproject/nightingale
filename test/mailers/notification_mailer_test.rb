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

  test 'notification email with comment from requested edits' do
    comment = Comment.create(content: 'requested edits', death_record: @dr, requested_edits: true)
    comment_contents = @dr.comments.where(requested_edits: true).collect(&:content)
    email = NotificationMailer.notification_email(@user, @dr, comment_contents).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert email.html_part.body.to_s.include?('requested edits')
    assert email.text_part.body.to_s.include?('requested edits')
  end

  test 'notification email with comment not from requested edits' do
    comment = Comment.create(content: 'requested edits', death_record: @dr, requested_edits: false)
    comment_contents = @dr.comments.where(requested_edits: true).collect(&:content)
    email = NotificationMailer.notification_email(@user, @dr, comment_contents).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_not email.html_part.body.to_s.include?('requested edits')
    assert_not email.text_part.body.to_s.include?('requested edits')
  end
end