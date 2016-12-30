# Headless Step Policy (no model associated with this policy file)
class StepPolicy
  def initialize(user, step)
    @user = user
    @step = step
  end

  def show?
    APP_CONFIG['death_record']['continue'].any? { |role| @user.has_role?(role) }
  end
end
