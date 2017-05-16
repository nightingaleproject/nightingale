# Reports Controller
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_is_admin

  def index
    @audits = Audited::Audit.all.order(created_at: :desc)
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
