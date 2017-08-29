require 'rails_helper'

feature 'User logs in then out', js: true do
  fixtures :users, :roles, :users_roles

  scenario 'successfully' do
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'My Open Records'
    dashboard_page.log_out
    login_page = Pages::Login.new
    expect(login_page).to have_content 'Sign in'
  end
end
