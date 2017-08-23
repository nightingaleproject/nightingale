# Rake tasks for checking Gemfile.lock for outdated gem versions.
require 'bundler/audit/cli'

namespace :bundler_audit do
  task :run do
    Bundler::Audit::CLI.new.update
    Bundler::Audit::CLI.new.check
  end
end
