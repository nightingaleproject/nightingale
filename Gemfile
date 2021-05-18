source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3'
# Use bootsnap to speed up application boot
gem 'bootsnap', require: false
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Authentication
gem 'devise'

# React for front end components
gem 'react-rails'

# Bootstrap 4
gem 'bootstrap', '4.3.1'

# User roles
gem 'rolify'

# Icons (major versions here normally break things, check for missing icons if you change this version)
gem 'font-awesome-sass', '~> 5.12'

# Creating local PDFs, useful unless a back-end service is used for generating certificates
gem 'prawn'
gem 'combine_pdf'

# Use audited for tracking ownership of records
gem 'audited', '~> 4.3'
gem 'rails-observers', git: 'https://github.com/rails/rails-observers'
gem 'hashdiff'

# JavaScript charts
gem 'chartkick'
gem 'groupdate'
gem 'bootstrap-datepicker-rails'

# Generate Rails routes for use in JavaScript
gem 'js-routes'

# Lodash for useful JavaScript functions
gem 'lodash-rails'

# Momentjs for handling dates/times in JavaScript
gem 'momentjs-rails'

# Easier configuration variables
gem 'config'

# Pagination
gem 'kaminari'

# VIEWS integration
gem 'views', git: 'https://github.com/nightingaleproject/views_connector'

# OAuth2
gem 'doorkeeper'

# IJE exporting
gem 'ije', git: 'https://github.com/nightingaleproject/ije'
gem 'codez'
gem 'StreetAddress'
gem 'geokit'

# FHIR
gem 'fhir_models', git: 'https://github.com/fhir-crucible/fhir_models'

gem "nokogiri", ">= 1.10.4"

gem 'rest-client'

group :development, :test, :ci do
  gem 'byebug', platform: :mri
  gem 'brakeman'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'database_cleaner'
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'fixtures_dumper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
