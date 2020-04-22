# lib/tasks/coverage_report.rake
namespace :coverage do
  task :report do
    require 'simplecov'

    SimpleCov.collate Dir["coverage/.resultset.json"], 'rails' do
      SimpleCov::Formatter::HTMLFormatter
    end
  end
end
