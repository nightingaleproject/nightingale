# Application Policy
class DeathRecordPolicy < ApplicationPolicy

  # Scope for determining which death records the current user can view.
  class Scope < Scope
    def resolve
      if !user.nil? && user.admin?
        scope.all
      elsif !user.nil?
        scope.where(user_id: user.id)
      end
    end
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def update?
    APP_CONFIG['death_record']['update'].any? { |role| user.has_role?(role) }
  end

  def create?
    APP_CONFIG['death_record']['create'].any? { |role| user.has_role?(role) }
  end

  def destroy?
    APP_CONFIG['death_record']['delete'].any? { |role| user.has_role?(role) }
  end
end
