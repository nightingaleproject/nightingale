require 'rails_helper'

feature 'UI notifications appear', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  scenario 'successfully' do
    # Log in as funeral director
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Start a new record, fill out first step, send to physician
    dashboard_page.create_record
    edit_identity_page = Pages::EditIdentity.new
    expect(edit_identity_page).to have_content 'Edit Death Record'
    edit_identity_page.fill_out self
    edit_identity_page.save_and_continue
    click_button 'progressButton4'
    review_fd_page = Pages::Review.new
    review_fd_page.send_to('doc1@example.com')
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    dashboard_page.log_out

    # See UI notifications
    login_page = Pages::Login.new
    login_page.sign_in_as 'doc1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(edit_identity_page).to have_content 'New!'
    dashboard_page.continue_record(1)
    edit_medical_page = Pages::EditMedical.new
    edit_medical_page.fill_out self
    edit_medical_page.save_and_continue

    # Don't see UI notifications when touched
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    expect(dashboard_page).to have_no_content 'New!'
  end
end
