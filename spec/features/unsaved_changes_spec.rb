require 'rails_helper'

feature 'Unsaved changed detected', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  scenario 'successfully' do
    # Log in as funeral director
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Start a new record, fill out first step, cancel
    dashboard_page.create_record
    edit_identity_page = Pages::EditIdentity.new
    expect(edit_identity_page).to have_content 'Edit Death Record'
    edit_identity_page.fill_out self
    click_button 'progressButton4'
    expect(edit_identity_page).to have_content 'You have unsaved changes!'
  end
end
