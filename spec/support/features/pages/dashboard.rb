module Pages
  class Dashboard
    include Capybara::DSL

    def open_count
      within('table#open_records') do
        return all(:css, '.btn').count
      end
    end

    def transferred_count
      within('table#transferred_records') do
        return all(:css, '.btn').count
      end
    end

    def log_out
      find(:linkhref, '/users/sign_out').click
    end

    def create_record
      find(:linkhref, '/death_records/new').click
    end

    def continue_record(id)
      visit "/death_records/#{id}/edit"
    end

    def view_record(id)
      visit "/death_records/#{id}"
    end
  end
end
