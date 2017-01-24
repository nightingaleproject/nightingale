# Question Policy
class Question::QuestionPolicy < ApplicationPolicy

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
    APP_CONFIG['question']['update'].any? { |role| user.has_role?(role) }
  end

  def create?
    APP_CONFIG['question']['create'].any? { |role| user.has_role?(role) }
  end

  def destroy?
    APP_CONFIG['question']['delete'].any? { |role| user.has_role?(role) }
  end
end
