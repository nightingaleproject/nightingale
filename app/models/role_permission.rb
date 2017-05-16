class RolePermission < ApplicationRecord
  audited
  validates_uniqueness_of :role
end
