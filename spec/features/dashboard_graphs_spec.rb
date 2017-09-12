require 'rails_helper'

feature 'Dashboard graphs appear', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  scenario 'successfully' do
    # Log in as funeral director
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'fd1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Nothing to show yet
    expect(dashboard_page).to have_content 'You currently have no open records.'
    expect(dashboard_page).to have_content 'You have not completed any death records yet.'

    # Create a record, return to dashboard
    dashboard_page.create_record
    edit_identity_page = Pages::EditIdentity.new
    expect(edit_identity_page).to have_content 'Edit Death Record'
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Should now see pie chart of open records, but no average completed
    expect(dashboard_page).to have_no_content 'You currently have no open records.'
    expect(dashboard_page).to have_content 'You have not completed any death records yet.'

    # Fill out a step
    dashboard_page.continue_record(1)
    edit_identity_page = Pages::EditIdentity.new
    expect(edit_identity_page).to have_content 'Edit Death Record'
    edit_identity_page.fill_out self
    edit_identity_page.save_and_continue

    # Should now see both open records age pie chart and average completion
    # bar chart.
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    expect(dashboard_page).to have_no_content 'You currently have no open records.'
    expect(dashboard_page).to have_no_content 'You have not completed any death records yet.'

    # Send to doc
    dashboard_page.continue_record(1)
    click_button 'progressButton4'
    review_fd_page = Pages::Review.new
    review_fd_page.send_to('doc1@example.com')
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Should see average completion, but no open records
    expect(dashboard_page).to have_content 'You currently have no open records.'
    expect(dashboard_page).to have_no_content 'You have not completed any death records yet.'
  end
end
