module Pages
  class Edit
    include Capybara::DSL

    def save_and_continue
      click_button('Save and Continue')
    end

    def cancel
      click_link('Cancel')
    end
  end
end
