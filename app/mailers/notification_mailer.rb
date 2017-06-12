# Mailer for Notifications
class NotificationMailer < ApplicationMailer
  def notification_email(user, death_record, comment, login_link)
    @user = user
    @death_record = death_record
    @comment = comment
    @link = login_link

    mail subject: 'Nightingale Notification', to: @user.email
  end
end
