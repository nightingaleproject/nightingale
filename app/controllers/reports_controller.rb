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
    audits = Audited::Audit.order(:created_at)
    if search.present?
      # FIXME: This search is still somewhat broken, and should be improved
      # Example issues: searching for fd1@example.com, results change significantly as typing continues
      filtered = audits.joins('JOIN users ON audits.user_id = users.id')
      filtered = filtered.where("to_tsvector(audited_changes) || to_tsvector(auditable_type) || to_tsvector(action) || to_tsvector(users.email) @@ to_tsquery(?)", "#{search.downcase}:*")
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
