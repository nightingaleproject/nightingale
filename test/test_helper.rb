ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'devise'

module ActiveSupport
  class TestCase
    fixtures :all
  end
end
