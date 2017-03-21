# User model
class User < ApplicationRecord
  rolify
  has_many :death_records
  has_many :comments
  has_many :user_tokens
  audited
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def admin?
    has_role?(:admin)
  end

  def registrar?
    has_role?(:registrar)
  end

  def grant_admin
    add_role :admin
    confirm unless confirmed?
  end

  def revoke_admin
    remove_role :admin
  end
end
