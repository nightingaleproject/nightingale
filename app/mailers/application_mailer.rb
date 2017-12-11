class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.action_mailer.default_url_options[:host]
  layout 'mailer'
end
