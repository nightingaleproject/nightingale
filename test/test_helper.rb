ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'devise'

module ActiveSupport
  class TestCase
    load "#{Rails.root}/db/seeds.rb"
    fixtures :all
  end
end
