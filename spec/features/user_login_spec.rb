require 'rails_helper'

feature 'User log in', js: true do
  fixtures :users, :roles, :users_roles

  #Capybara.current_driver = :selenium_chrome
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist

  scenario 'successfully' do
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Welcome'
  end
end
