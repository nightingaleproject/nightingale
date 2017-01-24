APP_CONFIG ||= {}
APP_CONFIG.merge! YAML.load_file(Rails.root.join('config/steps','step_config.yml'))[Rails.env]