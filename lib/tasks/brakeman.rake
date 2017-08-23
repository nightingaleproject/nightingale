# Rake tasks for running a brakeman scan.
require 'brakeman'

namespace :brakeman do
  task :run do
    tracker = Brakeman.run app_path: '.'
    if tracker.checks.all_warnings.length != 0
      fail "\033[31mBrakeman found security issues!\033[0m"
    end
  end
end
