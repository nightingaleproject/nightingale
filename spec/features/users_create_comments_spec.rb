require 'rails_helper'

feature 'Users create comments', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  scenario 'successfully' do
    # Log in as funeral director
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Start a new record.
    assert dashboard_page.open_count == 0
    dashboard_page.create_record
    edit_identity_page = Pages::Edit.new
    expect(edit_identity_page).to have_content 'Edit Death Record'

    # Create and submit a comment.
    fill_in 'commentArea', with: 'Long lasting comment.'
    click_button 'submitComment'
    expect(edit_identity_page).to have_content 'Long lasting comment.'
    fill_in 'commentArea', with: 'comment 2.'
    click_button 'submitComment'
    expect(edit_identity_page).to have_content 'comment 2.'
    click_button 'deleteComment2'
    expect(edit_identity_page).to have_no_content 'comment 2.'
    fill_in 'commentArea', with: 'comment 3.'
    click_button 'submitComment'
    expect(edit_identity_page).to have_content 'comment 3.'
    expect(edit_identity_page).to have_content 'Long lasting comment.'

    # Move to the review step.
    click_button 'progressButton4'
    review_fd_page = Pages::Review.new
    expect(review_fd_page).to have_content 'comment 3.'
    expect(review_fd_page).to have_content 'Long lasting comment.'
    click_button 'deleteComment3'
    expect(review_fd_page).to have_no_content 'comment 2.'
    expect(review_fd_page).to have_no_content 'comment 3.'
    expect(review_fd_page).to have_content 'Long lasting comment.'
    fill_in 'commentArea', with: 'comment 4.'
    click_button 'submitComment'
    expect(review_fd_page).to have_content 'comment 4.'
    expect(review_fd_page).to have_content 'Long lasting comment.'
    review_fd_page.send_to('doc1@example.com')

    # Go back to the dashboard, log out, continue as doc
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'doc1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Check comments from medical page
    dashboard_page.continue_record(1)
    edit_medical_page = Pages::EditMedical.new
    expect(edit_medical_page).to have_content 'comment 4.'
    expect(edit_medical_page).to have_content 'Long lasting comment.'
    fill_in 'commentArea', with: 'comment 5.'
    click_button 'submitComment'
    expect(edit_medical_page).to have_content 'comment 5.'
    edit_medical_page.save_and_continue

    review_physician_page = Pages::Review.new
    expect(review_physician_page).to have_content 'comment 4.'
    expect(review_physician_page).to have_content 'Long lasting comment.'
    expect(edit_medical_page).to have_content 'comment 5.'
    expect(edit_medical_page).to have_no_css('button#deleteComment4')

    # Continue to registrar, and check that comments are available
    review_physician_page.send_to('reg1@example.com')
    review_physician_page.attest
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'reg1@example.com', '123456'
    dashboard_page.view_record(1)
    expect(review_physician_page).to have_content 'comment 4.'
    expect(review_physician_page).to have_content 'Long lasting comment.'
    expect(edit_medical_page).to have_content 'comment 5.'
    expect(edit_medical_page).to have_no_css("button#deleteComment4")
  end
end
