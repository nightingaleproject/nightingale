require 'rails_helper'

feature 'Search for a comment in audit logs', js: true do
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

    # Go back to the dashboard, log out
    visit '/'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'
    dashboard_page.log_out
    login_page = Pages::Login.new
    login_page.sign_in_as 'admin@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Go to Admin panel
    dashboard_page.admin
    admin_panel_page = Pages::AdminPanel.new
    expect(admin_panel_page).to have_content 'Administration Tools'
    
    # Go to Audit log pages
    admin_panel_page.audit_log.click
    audit_log_page = Pages::AuditLog.new
    expect(audit_log_page).to have_content 'Search'

    # Search for Comment
    audit_log_page.search 'Comment'
    expect(audit_log_page).to have_selector(:xpath, '//*[@id="audits_table"]/tbody/tr[2]', wait: 3)
    assert audit_log_page.record_count == 2
  end
end
