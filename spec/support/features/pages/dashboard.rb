module Pages
    class Dashboard
      include Capybara::DSL
      
      def be_on_dashboard_page
        page.should have_content 'Welcome'
      end
    end
  end    