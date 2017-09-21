require 'rails_helper'

feature 'VIEWS validate', js: true do
  fixtures :users, :roles, :users_roles, :role_permissions, :steps, :step_flows, :workflows

  Capybara.default_max_wait_time = 10

  scenario 'successfully' do
    # Log in as a physician
    visit '/'
    login_page = Pages::Login.new
    login_page.sign_in_as 'doc1@example.com', '123456'
    dashboard_page = Pages::Dashboard.new
    expect(dashboard_page).to have_content 'Search by Name'

    # Start a new record
    dashboard_page.create_record
    edit_medical_page = Pages::EditMedical.new

    # Fill out Cause of Death
    expect(edit_medical_page).to have_content 'Cause of Death'
    within('fieldset#codfield') do
      fill_in 'immediate', with: 'Hart Attack'
      fill_in 'under1', with: 'qwerty1234'
      fill_in 'under2', with: 'Plague'
      fill_in 'under3', with: 'EX Obesity'
    end

    # Validate and check response
    within('fieldset#codfield') do
      click_button 'Validate'
    end
    expect(edit_medical_page).to have_content 'RareWord: "Hart"'
    expect(edit_medical_page).to have_content 'Spelling: VIEWS detected an issue with the spelling of \'qwerty1234\''
    expect(edit_medical_page).to have_content 'RareWord: "Plague"'
    expect(edit_medical_page).to have_content 'Abbreviation: EX'
  end
end
