require 'rails_helper'

feature 'User abandons a record', js: true do
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

    # Go back to the dashboard, check for record, then view it
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 1
    assert dashboard_page.transferred_count == 0
    dashboard_page.view_record(1)
    view_page = Pages::Review.new
    view_page.abandon

    # Make sure record is gone
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    assert dashboard_page.open_count == 0
    assert dashboard_page.transferred_count == 0
  end
end
