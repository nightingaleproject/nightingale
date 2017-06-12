require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Nightingale
  class Application < Rails::Application
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]
    config.autoload_paths += %W{#{config.root}/lib}
  end
end
