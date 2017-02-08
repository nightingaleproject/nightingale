class GuestMailer < ApplicationMailer

  def guest_user_email(user, link)
    @user = user
    @link = link
    mail :subject => "New Death Record to Review", :to => @user.email
  end
end