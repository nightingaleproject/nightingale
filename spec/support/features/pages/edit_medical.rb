module Pages
  class EditMedical < Edit
    # Check to make sure the progress status for medical is a green checkmark
    # on the sidebar (all required fields were entered for this step).
    def progress_passing(feature)
      find(:css, '#Medicalstatus')[:class].include? 'fa-check'
    end

    # Check to make sure the info entered on the medical page is rendered
    # correctly in human readable form (on the review step).
    def check_human_readable(feature, view=false)
      find('#Medical').click unless view
      feature.expect(self).to feature.have_content 'Inpatient'
      feature.expect(self).to feature.have_content 'Example Hospital'
      feature.expect(self).to feature.have_content '4 Example St.'
      feature.expect(self).to feature.have_content 'Bedford, MIDDLESEX, Massachusetts'
      feature.expect(self).to feature.have_content '01730'
      feature.expect(self).to feature.have_content '2017-01-01'
      feature.expect(self).to feature.have_content '00:00'
      feature.expect(self).to feature.have_content '0987654321'
      feature.expect(self).to feature.have_content '2017-01-01: Actual'
      feature.expect(self).to feature.have_content '00:00: Actual'
      feature.expect(self).to feature.have_content 'No'
      feature.expect(self).to feature.have_content 'Respiratory failure: 5 minutes'
      feature.expect(self).to feature.have_content 'Fentanyl overdose: 3 hours'
      feature.expect(self).to feature.have_content 'Opioid addiction: 2 years'
      feature.expect(self).to feature.have_content 'Prescription for opioids following workplace injury led to addiction.'
      feature.expect(self).to feature.have_content 'Not pregnant in the past year'
      feature.expect(self).to feature.have_content 'Natural'
      feature.expect(self).to feature.have_content 'Physician, Example Middle'
      feature.expect(self).to feature.have_content '5 Example St.'
      feature.expect(self).to feature.have_content '1029384756'
      feature.expect(self).to feature.have_content 'Pronouncing and Certifying Physician'
    end

    # Fill out the medical edit page.
    def fill_out(feature)
      feature.expect(self).to feature.have_content 'Place of Death'
      within('fieldset#placeOfDeathfield') do
        choose 'Inpatient'
      end
      feature.expect(self).to feature.have_content 'Location of Death'
      within('fieldset#locationOfDeathfield') do
        fill_in 'name', with: 'Example Hospital'
        fill_in 'locationOfDeathstate-input', with: 'Massachusetts'
        fill_in 'locationOfDeathcounty-input', with: 'MIDDLESEX'
        fill_in 'locationOfDeathcity-input', with: 'Bedford'
        fill_in 'locationOfDeathzip-input', with: '01730'
        fill_in 'locationOfDeathstreet-input', with: '4 Example St.'
      end
      feature.expect(self).to feature.have_content 'Date Pronounced Dead'
      within('fieldset#datePronouncedDeadfield') do
        fill_in 'datePronouncedDeadinput', with: '01/01/2017'
      end
      feature.expect(self).to feature.have_content 'Time Pronounced Dead'
      within('fieldset#timePronouncedDeadfield') do
        fill_in 'timePronouncedDeadinput', with: '12:00AM'
      end
      feature.expect(self).to feature.have_content 'Pronouncer\'s License Number'
      within('fieldset#pronouncerLicenseNumberfield') do
        fill_in 'pronouncerLicenseNumberinput', with: '0987654321'
      end
      feature.expect(self).to feature.have_content 'Date of Pronouncer\'s Signature'
      within('fieldset#dateOfPronouncerSignaturefield') do
        fill_in 'dateOfPronouncerSignatureinput', with: '01/01/2017'
      end
      feature.expect(self).to feature.have_content 'Date of Death'
      within('fieldset#dateOfDeathfield') do
        choose 'Actual'
        fill_in 'dateOfDeathinput', with: '01/01/2017'
      end
      feature.expect(self).to feature.have_content 'Time of Death'
      within('fieldset#timeOfDeathfield') do
        choose 'Actual'
        fill_in 'timeOfDeathinput', with: '12:00AM'
      end
      feature.expect(self).to feature.have_content 'ME or Coroner Contacted?'
      within('fieldset#meOrCoronerContactedfield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Autopsy Performed?'
      within('fieldset#autopsyPerformedfield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Autopsy Available to Complete Cause of Death?'
      within('fieldset#autopsyAvailableToCompleteCauseOfDeathfield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Cause of Death'
      within('fieldset#codfield') do
        fill_in 'immediate', with: 'Respiratory failure'
        fill_in 'immediateInt', with: '5 minutes'
        fill_in 'under1', with: 'Fentanyl overdose'
        fill_in 'under1Int', with: '3 hours'
        fill_in 'under2', with: 'Opioid addiction'
        fill_in 'under2Int', with: '2 years'
      end
      feature.expect(self).to feature.have_content 'Contributing Causes'
      within('fieldset#contributingCausesfield') do
        fill_in 'contributingCausesarea', with: 'Prescription for opioids following workplace injury led to addiction.'
      end
      feature.expect(self).to feature.have_content 'Did Tobacco Use Contribute to Death?'
      within('fieldset#didTobaccoUseContributeToDeathfield') do
        choose 'No'
      end
      feature.expect(self).to feature.have_content 'Pregnancy Status'
      within('fieldset#pregnancyStatusfield') do
        choose 'Not pregnant in the past year'
      end
      feature.expect(self).to feature.have_content 'Manner of Death'
      within('fieldset#mannerOfDeathfield') do
        choose 'Natural'
      end
      feature.expect(self).to feature.have_content 'Name of Person Completing Cause of Death'
      within('fieldset#personCompletingCauseOfDeathNamefield') do
        within('div#actual') do
          fill_in 'first', with: 'Example'
          fill_in 'middle', with: 'Middle'
          fill_in 'last', with: 'Physician'
        end
      end
      feature.expect(self).to feature.have_content 'Address of Person Completing Cause of Death'
      within('fieldset#personCompletingCauseOfDeathAddressfield') do
        fill_in 'personCompletingCauseOfDeathAddressstate-input', with: 'Massachusetts'
        fill_in 'personCompletingCauseOfDeathAddresscounty-input', with: 'MIDDLESEX'
        fill_in 'personCompletingCauseOfDeathAddresscity-input', with: 'Bedford'
        fill_in 'personCompletingCauseOfDeathAddresszip-input', with: '01730'
        fill_in 'personCompletingCauseOfDeathAddressstreet-input', with: '5 Example St.'
      end
      feature.expect(self).to feature.have_content 'License Number of Person Completing Cause of Death'
      within('fieldset#personCompletingCauseOfDeathLicenseNumberfield') do
        fill_in 'personCompletingCauseOfDeathLicenseNumberinput', with: '1029384756'
      end
      feature.expect(self).to feature.have_content 'Certifier Type'
      within('fieldset#certifierTypefield') do
        choose 'Pronouncing and Certifying Physician'
      end
      feature.expect(self).to feature.have_content 'Date Certified'
      within('fieldset#dateCertifiedfield') do
        fill_in 'dateCertifiedinput', with: '01/01/2017'
      end
    end
  end
end
