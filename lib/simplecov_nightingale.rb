require 'simplecov'
SimpleCov.profiles.define 'nightingale' do
  load_profile 'rails'
  add_filter 'lib' # Don't include lib directory
  formatter SimpleCov::Formatter::SimpleFormatter
end
