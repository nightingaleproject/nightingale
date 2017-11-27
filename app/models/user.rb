class User < ApplicationRecord
  audited except: [:encrypted_password, :reset_password_token]
  rolify

  devise :database_authenticatable, :registerable, :recoverable,
         :trackable, :validatable

  has_many :owned_death_records, class_name: 'DeathRecord', foreign_key: 'owner_id'
  has_many :created_death_records, class_name: 'DeathRecord', foreign_key: 'creator_id'
  has_many :comments
  has_many :step_status
  has_many :user_contents
  has_many :step_histories
  has_many :user_tokens

  def admin?
    return false if is_guest_user
    has_role?(:admin)
  end

  def registrar?
    return false if is_guest_user
    has_role?(:registrar)
  end

  def can_start_record?
    return false if is_guest_user
    roles.each do |role|
      return true if RolePermission.find_by(role: role.name).try(:can_start_record)
    end
    false
  end

  def can_register_record?
    return false if is_guest_user
    roles.each do |role|
      return true if RolePermission.find_by(role: role.name).try(:can_register_record)
    end
    false
  end

  def can_request_edits?
    return false if is_guest_user
    roles.each do |role|
      return true if RolePermission.find_by(role: role.name).try(:can_request_edits)
    end
    false
  end

  def can_abandon_record(death_record)
    return false if is_guest_user
    self.id == death_record.creator.id
  end

  def grant_admin
    return false if is_guest_user
    add_role :admin unless has_role?(:admin)
  end

  def revoke_admin
    remove_role :admin if has_role?(:admin)
  end

  def as_json(options = {})
    {
      id: self.id,
      name: NameHelper.pretty_user_name(self),
      email: self.email,
      role: self.roles.first.name,
      rolePretty: self.roles.first.name.humanize.titleize,
      canStartRecord: can_start_record?,
      canRegisterRecord: can_register_record?,
      canRequestEdits: can_request_edits?,
      isAdmin: admin?,
      isRegistrar: registrar?
    }
  end
end
