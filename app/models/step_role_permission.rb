# Steps to Roles Model
class StepRolePermission < ApplicationRecord
  belongs_to :step, class_name: 'Step', foreign_key: :step_id
  belongs_to :role, class_name: 'Role', foreign_key: :role_id
end
