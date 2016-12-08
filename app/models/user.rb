# User model
class User < ApplicationRecord
  rolify
  has_many :death_records
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def admin?
    has_role?(:admin)
  end

  def grant_admin
    add_role :admin
    confirm unless confirmed?
  end

  def revoke_admin
    remove_role :admin
  end
end
