# Reports Controller
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_is_admin

  def index
  end

  def audit_logs
    length = params[:length].to_i
    page = params[:start].to_i == 0 ? 1 : (params[:start].to_i / length) + 1
    draw = params[:draw].to_i
    search = params[:search][:value] unless params[:search].nil?
    audits = Audited::Audit.all
    if search.present?
      # Use Postgres free text search to search for audited_changes, auditable_type and action
      filtered = audits.includes(:user).where("to_tsvector('english', audited_changes) || to_tsvector('english', auditable_type) || to_tsvector('english', action) || to_tsvector('english', user) @@ to_tsquery(?)", "%#{search.downcase}%")
    else
      filtered = audits
    end
      # NOTES:
      # 'data' is the array of records
      # 'recordsTotal' is the TOTAL number of records
      # 'recordsFiltered' is the number of records AFTER filtering (but not after pagination!)
      render json: {data: filtered.page(page).per(length).as_json(include: :user), draw: draw, recordsTotal: audits.count, recordsFiltered: filtered.count}
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
