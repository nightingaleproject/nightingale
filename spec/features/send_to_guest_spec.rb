require 'rails_helper'

feature 'Sending a record to a guest', js: true do
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

    # Send the record to a guest physician.
    click_button 'progressButton4'
    review_fd_page = Pages::Review.new
    review_fd_page.send_to_guest('guest_doc@example.com')
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Log out of funeral director, log in as guest physician
    dashboard_page.log_out
    guest = User.find_by(email: 'guest_doc@example.com')
    assert guest.is_guest_user
    token = guest.user_tokens.first.token
    visit '/guest_users/' + token

    # Fill out medical step, save and continue
    edit_medical_page = Pages::EditMedical.new
    edit_medical_page.fill_out self
    edit_medical_page.save_and_continue
    expect(edit_page).to have_content 'Send to'
    review_physician_page = Pages::Review.new
    review_physician_page.send_to('reg1@example.com')
    review_physician_page.attest

    # Make sure we are back on log in page
    login_page = Pages::Login.new
    expect(login_page).to have_content 'Sign in'
  end
end
