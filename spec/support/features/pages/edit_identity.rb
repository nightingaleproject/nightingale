module Pages
  class EditIdentity < Edit
    # Check to make sure the progress status for identity is a green checkmark
    # on the sidebar (all required fields were entered for this step).
    def progress_passing(feature)
      find(:css, '#Identitystatus')[:class].include? 'fa-check'
    end

    # Check to make sure the info entered on the identity page is rendered
    # correctly in human readable form (on the review step).
    def check_human_readable(feature, view=false)
      find('#Identity').click unless view
      feature.expect(self).to feature.have_content 'Person, Example Middle Jr.'
      feature.expect(self).to feature.have_content '111-22-3333'
      feature.expect(self).to feature.have_content '1 Example St. Unit 1'
      feature.expect(self).to feature.have_content 'Bedford, MIDDLESEX, Massachusetts'
      feature.expect(self).to feature.have_content '01730'
    end

    # Fill out the identity edit page.
    def fill_out(feature)
      feature.expect(self).to feature.have_content 'Decedent\'s Legal Name'
      within('fieldset#decedentNamefield') do
        within('div#actual') do
          fill_in 'first', with: 'Example'
          fill_in 'middle', with: 'Middle'
          fill_in 'last', with: 'Person'
          fill_in 'suffix', with: 'Jr.'
        end
      end
      feature.expect(self).to feature.have_button('add-aka', disabled: false)
      within('div#aka0') do
        fill_in 'first', with: 'aka'
        fill_in 'last', with: '0'
      end
      click_button 'add-aka'
      within('div#aka1') do
        fill_in 'first', with: 'aka'
        fill_in 'last', with: '1'
      end
      click_button 'add-aka'
      within('div#aka2') do
        fill_in 'first', with: 'aka'
        fill_in 'last', with: '2'
      end
      click_button 'add-aka'
      within('div#aka3') do
        fill_in 'first', with: 'aka'
        fill_in 'last', with: '3'
      end
      click_button 'add-aka'
      within('div#aka4') do
        fill_in 'first', with: 'aka'
        fill_in 'last', with: '4'
      end
      feature.expect(self).to feature.have_button('add-aka', disabled: true)
      feature.expect(self).to feature.have_content 'Social Security Number'
      within('fieldset#ssnfield') do
        fill_in 'ssn-1', with: '111'
        fill_in 'ssn-2', with: '22'
        fill_in 'ssn-3', with: '3333'
      end
      feature.expect(self).to feature.have_content 'Decedent\'s Residence'
      within('fieldset#decedentAddressfield') do
        fill_in 'decedentAddressstate-input', with: 'Massachusetts'
        fill_in 'decedentAddresscounty-input', with: 'MIDDLESEX'
        fill_in 'decedentAddresscity-input', with: 'Bedford'
        fill_in 'decedentAddresszip-input', with: '01730'
        fill_in 'decedentAddressstreet-input', with: '1 Example St.'
        fill_in 'decedentAddressapt-input', with: 'Unit 1'
      end
      # Check that metadata was updated on the sidebar.
      feature.expect(self).to feature.have_content 'Person, Example M. Jr.'
      feature.expect(self).to feature.have_content '111-22-3333'
    end
  end
end
