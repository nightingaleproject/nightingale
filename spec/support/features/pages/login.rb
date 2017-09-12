module Pages
  class Login
    include Capybara::DSL

    def sign_in_as(email, password)
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      click_button 'Log in'
    end
  end
end
