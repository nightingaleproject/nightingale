module Pages
  class EditFamily < Edit
    # Check to make sure the progress status for family is a green checkmark
    # (all required fields were entered for this step).
    def progress_passing(feature)
      find(:css, '#Familystatus')[:class].include? 'fa-check'
    end

    # Check to make sure the info entered on the family page is rendered
    # correctly in human readable form (on the review step).
    def check_human_readable(feature, view=false)
      find('#Family').click unless view
      feature.expect(self).to feature.have_content 'Person, Spouse Middle'
      feature.expect(self).to feature.have_content 'Person, Father Middle Sr.'
      feature.expect(self).to feature.have_content 'Maiden, Mother Middle'
    end

    # Fill out the family edit page.
    def fill_out(feature)
      feature.expect(self).to feature.have_content 'Surviving Spouse\'s Name'
      within('fieldset#spouseNamefield') do
        within('div#actual') do
          fill_in 'first', with: 'Spouse'
          fill_in 'middle', with: 'Middle'
          fill_in 'last', with: 'Person'
        end
      end
      feature.expect(self).to feature.have_content 'Father\'s Name'
      within('fieldset#fatherNamefield') do
        within('div#actual') do
          fill_in 'first', with: 'Father'
          fill_in 'middle', with: 'Middle'
          fill_in 'last', with: 'Person'
          fill_in 'suffix', with: 'Sr.'
        end
      end
      feature.expect(self).to feature.have_content 'Mother\'s Name'
      within('fieldset#motherNamefield') do
        within('div#actual') do
          fill_in 'first', with: 'Mother'
          fill_in 'middle', with: 'Middle'
          fill_in 'last', with: 'Maiden'
        end
      end
    end
  end
end
