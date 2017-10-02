require 'rails_helper'

feature 'Complete demo workflow', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  Capybara.default_max_wait_time = 10

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

    # Fill out demographics step, save and continue
    edit_demographics_page = Pages::EditDemographics.new
    edit_demographics_page.fill_out self
    edit_demographics_page.save_and_continue

    # Fill out family step, save and continue
    edit_family_page = Pages::EditFamily.new
    edit_family_page.fill_out self
    edit_family_page.save_and_continue

    # Fill out disposition step, save and continue
    edit_disposition_page = Pages::EditDisposition.new
    edit_disposition_page.fill_out self
    edit_disposition_page.save_and_continue

    # On funeral director review page, make sure the human readables
    # were rendered correctly.
    edit_identity_page.check_human_readable self
    edit_demographics_page.check_human_readable self
    edit_family_page.check_human_readable self
    edit_disposition_page.check_human_readable self

    # On funeral director review page, make sure the progress check marks
    # are present (all required fields were included)?
    assert edit_identity_page.progress_passing self
    assert edit_demographics_page.progress_passing self
    assert edit_family_page.progress_passing self
    assert edit_disposition_page.progress_passing self

    # Go back to the dashboard, check the progress, then reopen the record
    edit_disposition_page.cancel
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.find_by_id('Identityprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Demographicsprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Familyprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Dispositionprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Medicalprog')[:class].include? 'fa-circle-o'
    assert dashboard_page.open_count == 1
    dashboard_page.continue_record(1)

    # Send the record to a physician, then check that the record is under
    # transferred on the dashboard.
    review_fd_page = Pages::Review.new
    review_fd_page.send_to('doc1@example.com')
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 0
    assert dashboard_page.transferred_count == 1

    # Log out of funeral director, log in as physician
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'doc1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Person, Example M. Jr.'
    assert dashboard_page.open_count == 1
    assert dashboard_page.transferred_count == 0

    # Fill out medical step, save and continue
    dashboard_page.continue_record(1)
    edit_medical_page = Pages::EditMedical.new
    edit_medical_page.fill_out self
    edit_medical_page.save_and_continue

    # On physician review page, make sure the human readables
    # were rendered correctly.
    edit_identity_page.check_human_readable self
    edit_demographics_page.check_human_readable self
    edit_family_page.check_human_readable self
    edit_disposition_page.check_human_readable self
    edit_medical_page.check_human_readable self

    # On physician review page, make sure the progress check marks
    # are present (all required fields were included)?
    assert edit_identity_page.progress_passing self
    assert edit_demographics_page.progress_passing self
    assert edit_family_page.progress_passing self
    assert edit_disposition_page.progress_passing self
    assert edit_medical_page.progress_passing self

    # Send the record to a registrar, then check that the record is under
    # transferred on the dashboard.
    review_physician_page = Pages::Review.new
    review_physician_page.send_to('reg1@example.com')
    review_physician_page.attest
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 0
    assert dashboard_page.transferred_count == 1

    # Log out of physician, log in as registrar
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'reg1@example.com', '123456'

    # Make sure record is present, and that progress is correct
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Person, Example M. Jr.'
    assert dashboard_page.open_count == 1
    assert dashboard_page.transferred_count == 0
    assert dashboard_page.find_by_id('Identityprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Demographicsprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Familyprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Dispositionprog')[:class].include? 'fa-check-circle'
    assert dashboard_page.find_by_id('Medicalprog')[:class].include? 'fa-check-circle'

    # View record, check status, then register
    dashboard_page.view_record(1)
    review_registrar_page = Pages::Review.new
    edit_identity_page.check_human_readable self, true
    edit_demographics_page.check_human_readable self, true
    edit_family_page.check_human_readable self, true
    edit_disposition_page.check_human_readable self, true
    edit_medical_page.check_human_readable self, true
    review_registrar_page.register
    expect(review_registrar_page).to have_content 'Registered at'

    # Check the dashboard
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    expect(dashboard_page).to have_content 'Registered!'

    # Log out, log in as admin, make sure record is visible
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'admin@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Person, Example M. Jr.'
    expect(dashboard_page).to have_content 'Registered!'
  end
end
