module Pages
  class AuditLog
    include Capybara::DSL
  
    def search(search_string)
      find(:xpath, '//*[@id="audits_table_filter"]/label/input').set(search_string)
    end
  end
end
