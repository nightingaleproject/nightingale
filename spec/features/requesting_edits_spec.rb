require 'rails_helper'

feature 'Requesting edits', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  scenario 'successfully' do

    # Log in as funeral director
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Start a new record
    assert dashboard_page.open_count == 0
    dashboard_page.create_record
    edit_page = Pages::Edit.new
    expect(edit_page).to have_content 'Edit Death Record'

    # Fill out identity step, save and continue
    edit_identity_page = Pages::EditIdentity.new
    edit_identity_page.fill_out self
    edit_identity_page.save_and_continue

    # Send to doc, log out
    click_button 'progressButton4'
    review_fd_page = Pages::Review.new
    review_fd_page.send_to('doc1@example.com')
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 0
    assert dashboard_page.transferred_count == 1
    dashboard_page.log_out

    # Log in as doc
    login_page = Pages::Login.new
    login_page.sign_in_as 'doc1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Person, Example M. Jr.'
    assert dashboard_page.open_count == 1
    assert dashboard_page.transferred_count == 0

    # Continue record, fill out medical
    dashboard_page.continue_record(1)
    edit_medical_page = Pages::EditMedical.new
    edit_medical_page.fill_out self
    edit_medical_page.save_and_continue
    review_physician_page = Pages::Review.new

    # Doctor doesn't like demographics not being filled out, asks for edits
    within('div#Demographics') do
      expect(review_physician_page).to have_content 'Some required fields are not complete!'
    end
    click_button 'DemographicsRequestEditsButton'
    expect(review_physician_page).to have_content 'You are requesting edits from fd1@example.com'
    review_physician_page.request_edits('Demographics info is blank!')

    # Log out, log back in as fd
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 0
    assert dashboard_page.transferred_count == 1
    dashboard_page.log_out
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 1
    assert dashboard_page.transferred_count == 0

    # Check record at step with comment
    dashboard_page.continue_record(1)
    edit_demographics_page = Pages::EditDemographics.new
    expect(edit_demographics_page).to have_content 'Edit Death Record'
    expect(edit_demographics_page).to have_content 'Demographics info is blank!'
    edit_demographics_page.fill_out self
    edit_demographics_page.save_and_continue
  end
end
