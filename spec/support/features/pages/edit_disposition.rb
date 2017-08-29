module Pages
  class EditDisposition < Edit
    # Check to make sure the progress status for disposition is a green
    # checkmark (all required fields were entered for this step).
    def progress_passing(feature)
      find(:css, '#Dispositionstatus')[:class].include? 'fa-check'
    end

    # Check to make sure the info entered on the disposition page is rendered
    # correctly in human readable form (on the review step).
    def check_human_readable(feature, view=false)
      find('#Disposition').click unless view
      feature.expect(self).to feature.have_content 'Burial'
      feature.expect(self).to feature.have_content '111-22-3333'
      feature.expect(self).to feature.have_content 'Example Cemetery'
      feature.expect(self).to feature.have_content 'Bedford, Massachusetts, United States'
      feature.expect(self).to feature.have_content 'Example Funeral Home'
      feature.expect(self).to feature.have_content '2 Example St.'
      feature.expect(self).to feature.have_content 'Bedford, MIDDLESEX, Massachusetts'
      feature.expect(self).to feature.have_content '01730'
      feature.expect(self).to feature.have_content '1234567890'
      feature.expect(self).to feature.have_content 'Person, Brother Middle'
      feature.expect(self).to feature.have_content '3 Example St.'
    end

    # Fill out the disposition edit page.
    def fill_out(feature)
      feature.expect(self).to feature.have_content 'Method of Disposition'
      within('fieldset#methodOfDispositionfield') do
        choose 'Burial'
      end
      feature.expect(self).to feature.have_content 'Place of Disposition'
      within('fieldset#placeOfDispositionfield') do
        fill_in 'name', with: 'Example Cemetery'
        fill_in 'placeOfDispositioncountry-input', with: 'United States'
        fill_in 'placeOfDispositionstate-input', with: 'Massachusetts'
        fill_in 'placeOfDispositioncity-input', with: 'Bedford'
      end
      feature.expect(self).to feature.have_content 'Funeral Facility'
      within('fieldset#funeralFacilityfield') do
        fill_in 'name', with: 'Example Funeral Home'
        fill_in 'funeralFacilitystate-input', with: 'Massachusetts'
        fill_in 'funeralFacilitycounty-input', with: 'MIDDLESEX'
        fill_in 'funeralFacilitycity-input', with: 'Bedford'
        fill_in 'funeralFacilityzip-input', with: '01730'
        fill_in 'funeralFacilitystreet-input', with: '2 Example St.'
      end
      feature.expect(self).to feature.have_content 'Funeral Service License Number'
      within('fieldset#funeralLicenseNumberfield') do
        fill_in 'funeralLicenseNumberinput', with: '1234567890'
      end
      feature.expect(self).to feature.have_content 'Informant\'s Name'
      within('fieldset#informantNamefield') do
        fill_in 'first', with: 'Brother'
        fill_in 'middle', with: 'Middle'
        fill_in 'last', with: 'Person'
      end
      feature.expect(self).to feature.have_content 'Informant\'s Address'
      within('fieldset#informantAddressfield') do
        fill_in 'informantAddressstate-input', with: 'Massachusetts'
        fill_in 'informantAddresscounty-input', with: 'MIDDLESEX'
        fill_in 'informantAddresscity-input', with: 'Bedford'
        fill_in 'informantAddresszip-input', with: '01730'
        fill_in 'informantAddressstreet-input', with: '3 Example St.'
      end
    end
  end
end
