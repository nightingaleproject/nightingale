APP_CONFIG ||= {}
APP_CONFIG.merge! YAML.load_file(Rails.root.join('config/permissions','permission_config.yml'))[Rails.env]