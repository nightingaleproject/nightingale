module Pages
    class AdminPanel
      include Capybara::DSL
 
      def log_out
        find(:linkhref, '/users/sign_out').click
      end
  
      def user_accounts
        find(:linkhref, '/users').click
      end
  
      def audit_log
        find(:linkhref, '/reports').click
      end
  
      def statistics
        find(:linkhref, '/statistics').click
      end
  
      def records_analysis
        find(:linkhref, '/analysis').click
      end
    end
  end
  