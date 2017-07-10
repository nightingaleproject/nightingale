# Mailer for Notifications
class NotificationMailer < ApplicationMailer
  def notification_email(user, death_record, comments)
    @user = user
    @death_record = death_record
    @comments = comments

    mail subject: 'Nightingale Notification', to: @user.email
  end
end
