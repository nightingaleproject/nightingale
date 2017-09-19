require 'rails_helper'

feature 'User changes account information', js: true do
  fixtures :users, :roles, :users_roles

  scenario 'successfully' do
    # Log in, navigate to My Account page
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'My Open Records'
    visit '/users/edit'

    # Check that current account details are correct
    expect(dashboard_page).to have_selector("input[value='Example']")
    expect(dashboard_page).to have_selector("input[value='FD']")
    expect(dashboard_page).to have_selector("input[value='000-000-0000']")

    # Change password and some account details
    fill_in 'user_current_password', with: '123456'
    fill_in 'user_password', with: '7654321'
    fill_in 'user_password_confirmation', with: '7654321'
    fill_in 'user_first_name', with: 'Red'
    fill_in 'user_last_name', with: 'Blue'
    fill_in 'user_telephone', with: '111-222-3333'
    click_button('update')

    # Log out, log back in with new password, check changed account details
    dashboard_page.log_out
    login_page = Pages::Login.new
    expect(login_page).to have_content 'Sign in'
    login_page.sign_in_as 'fd1@example.com', '7654321'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'My Open Records'
    visit '/users/edit'
    expect(dashboard_page).to have_selector("input[value='Red']")
    expect(dashboard_page).to have_selector("input[value='Blue']")
    expect(dashboard_page).to have_selector("input[value='111-222-3333']")
  end
end
