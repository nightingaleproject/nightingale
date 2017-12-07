module Pages
  class EditDemographics < Edit
    # Check to make sure the progress status for demographics is a green
    # checkmark (all required fields were entered for this step).
    def progress_passing(feature)
      find(:css, '#Demographicsstatus')[:class].include? 'fa-check'
    end

    # Check to make sure the info entered on the demographics page is rendered
    # correctly in human readable form (on the review step).
    def check_human_readable(feature, view=false)
      find('#Demographics').click unless view
      feature.expect(self).to feature.have_content 'Male'
      feature.expect(self).to feature.have_content '1970-01-01'
      feature.expect(self).to feature.have_content 'United States, Massachusetts, Bedford'
      feature.expect(self).to feature.have_content 'No'
      feature.expect(self).to feature.have_content 'Married'
      feature.expect(self).to feature.have_content 'Bachelor\'s degree'
      feature.expect(self).to feature.have_content 'Known, White'
      feature.expect(self).to feature.have_content 'Example1'
      feature.expect(self).to feature.have_content 'Example2'
    end

    # Fill out the demographics edit page.
    def fill_out(feature)
      feature.expect(self).to feature.have_content 'Sex'
      within('fieldset#sexfield') do
        choose 'Male'
      end
      feature.expect(self).to feature.have_content 'Date of Birth'
      within('fieldset#dateOfBirthfield') do
        fill_in 'dateOfBirthinput', with: '01/01/1970'
      end
      feature.expect(self).to feature.have_content 'Place of Birth'
      within('fieldset#placeOfBirthfield') do
        fill_in 'placeOfBirthcountry-input', with: 'United States'
        fill_in 'placeOfBirthstate-input', with: 'Massachusetts'
        fill_in 'placeOfBirthcity-input', with: 'Bedford'
      end
      feature.expect(self).to feature.have_content 'Armed Forces Service'
      within('fieldset#armedForcesServicefield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Marital Status'
      within('fieldset#maritalStatusfield') do
        choose 'Married'
      end
      feature.expect(self).to feature.have_content 'Education'
      within('fieldset#educationfield') do
        choose 'Bachelor\'s degree'
      end
      feature.expect(self).to feature.have_content 'Hispanic Origin'
      within('fieldset#hispanicOriginfield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Race'
      within('fieldset#racefield') do
        choose 'Known'
        check 'White'
      end
      feature.expect(self).to feature.have_content 'Usual Occupation'
      within('fieldset#usualOccupationfield') do
        fill_in 'usualOccupationarea', with: 'Example1'
      end
      feature.expect(self).to feature.have_content 'Kind Of Business'
      within('fieldset#kindOfBusinessfield') do
        fill_in 'kindOfBusinessarea', with: 'Example2'
      end
    end
  end
end
