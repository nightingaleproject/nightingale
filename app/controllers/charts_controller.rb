# Charts controller for manipulating line chart with form.
class ChartsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_is_admin

  before_action :load_data
  before_action :format_dates

  def create
    respond_to do |format|
      format.js
    end
  end

  def by_day
    opts = ['created_at', { range: @start_date..@end_date, format: '%d %b' }]
    method_name = :group_by_day
    if by_year?
      opts[1][:format] = '%Y'
      method_name = :group_by_year
    elsif by_month?
      opts[1][:format] = '%b %Y'
      method_name = :group_by_month
    end
    results = @results.send(method_name, *opts).count
    render json: [{ name: 'Count', data: results }].chart_json
  end

  private

  # If these strings change, change the same string in "reports/index.html.erb"
  # If death_records_created is changed, also change it in statistics_helper.rb
  def load_data
    if params[:query_action] == 'death_records_created'
      @results = Audited::Audit.where(auditable_type: :DeathRecord, action: :create)
    elsif params[:query_action] == 'death_records_completed'
      @results = Audited::Audit.where("to_tsvector('english', audited_changes) @@ to_tsquery(?)", 'time_registered').where(action: :update)
    elsif params[:query_action] == 'users_created'
      @results = User.all
    elsif params[:query_action] == 'users_sign_in'
      @results = Audited::Audit.where("to_tsvector('english', audited_changes) @@ to_tsquery(?)", 'current_sign_in_at').where(action: :update)
    else
      return
    end
  end

  # If one of the dates is empty, we populate is with a default value.
  # If the date is not empty, convert it to datetime (because initially it is a string).
  # Lastly, we swap the date if the end date comes after the start date.
  def format_dates
    @start_date = params[:start_date].nil? || params[:start_date].empty? ? 1.month.ago.midnight : params[:start_date].to_datetime.midnight
    @end_date = params[:end_date].nil? || params[:end_date].empty? ? Time.current.at_end_of_day : params[:end_date].to_datetime.at_end_of_day
    @start_date, @end_date = @end_date, @start_date if @end_date < @start_date
  end

  def by_year?
    @end_date - (1.year + 2.days) > @start_date
  end

  def by_month?
    @end_date - (3.months + 2.days) > @start_date
  end

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
