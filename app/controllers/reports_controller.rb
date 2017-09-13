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
    records = Audited::Audit.all
    if search.present?
      filtered = records.where('lower(name) like ?', "%#{search.downcase}%")
    else
      filtered = records
    end
      # NOTES:
      # 'data' is the array of records
      # 'recordsTotal' is the TOTAL number of records
      # 'recordsFiltered' is the number of records AFTER filtering (but not after pagination!)
      render json: {data: filtered.page(page).per(length), draw: draw, recordsTotal: records.count, recordsFiltered: filtered.count}
  end

#    @audits = Audited::Audit.all.order(created_at: :desc)
 # end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
