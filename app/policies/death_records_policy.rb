# Application Policy
class DeathRecordsPolicy < ApplicationPolicy

  # Scope for determining which death records the current user can view.
  class Scope < Scope
    def resolve
      if user.admin?
          scope.all
      else
          scope.where(user_id: user.id)
      end
    end
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def update?
    user.admin?    
  end

end
