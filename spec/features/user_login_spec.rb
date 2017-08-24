require 'rails_helper'

feature 'User log in' do
  fixtures :users, :roles, :users_roles
  debugger
  # Uncomment this line if you want the test to run in browser.
  # Capybara.current_driver = :selenium_chrome  

  scenario 'successfully' do
    visit '/'    
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to be_on_dashboard_page
  end
end