require 'custom_step_contents_audit'

Audited.config do |config|
  config.audit_class = CustomStepContentsAudit
end
