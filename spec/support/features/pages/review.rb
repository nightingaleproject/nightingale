module Pages
  class Review
    include Capybara::DSL

    def send_to(email)
      options = find('#email').all('option').collect(&:text)
      option = options.select { |opt| opt.include? email }.first
      select option, from: 'email'
      click_button 'Send'
    end

    def send_to_guest(email)
      find(:linkhref, '#guest').click
      fill_in 'guestEmail', with: email
      fill_in 'confirmEmail', with: email
      click_button 'Send'
    end

    def attest
      within '.sweet-alert.visible' do
        click_button 'I attest this record.'
      end
    end

    def register
      click_button 'registerBtn'
      within '.sweet-alert.visible' do
        click_button 'Register'
      end
      within '.sweet-alert.visible' do
        click_button 'OK'
      end
    end

    def abandon
      click_button 'abandonBtn'
      within '.sweet-alert.visible' do
        click_button 'Abandon!'
      end
      all(:css, '.hideSweetAlert')
    end

    def request_edits(reason)
      within '.sweet-alert.visible' do
        find(:css, 'input').set(reason)
        click_button 'Request Edits'
      end
      all(:css, '.hideSweetAlert')
    end
  end
end
