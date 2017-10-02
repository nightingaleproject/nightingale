module Pages
    class AuditLog
      include Capybara::DSL
  
      def search(search_string)
        find(:xpath, '//*[@id="audits_table_filter"]/label/input').set(search_string)
      end
      
      def record_count
        return all(:xpath, '//*[@id="audits_table"]/tbody/tr').count
      end
    end
  end
  