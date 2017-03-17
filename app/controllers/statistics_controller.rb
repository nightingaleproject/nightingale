# Statistics controller
class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def index
    verify_is_admin
  end

  # Generate a line chart representing all death records created over the
  # given start date to end date.
  def line_death_records_created
    verify_is_admin
    chart = StatisticsHelper.line_death_records_created(params[:start_date], params[:end_date])
    render html: chart.html_safe
  end

  # Generate a line chart representing all death records completions over the
  # given start date to end date.
  def line_death_records_completed
    verify_is_admin
    chart = StatisticsHelper.line_death_records_completed(params[:start_date], params[:end_date])
    render html: chart.html_safe
  end

  # Generate a line chart representing new user sign ups over the
  # given start date to end date.
  def line_users_created
    verify_is_admin
    chart = StatisticsHelper.line_users_created(params[:start_date], params[:end_date])
    render html: chart.html_safe
  end

  # Generate a line chart representing all user sign ins over the
  # given start date to end date.
  def line_user_sign_ins
    verify_is_admin
    chart = StatisticsHelper.line_user_sign_ins(params[:start_date], params[:end_date])
    render html: chart.html_safe
  end

  # Generate a pie chart representing death records by their current
  # step.
  def pie_death_records_by_step
    verify_is_admin
    chart = StatisticsHelper.pie_death_records_by_step
    render html: chart.html_safe
  end

  # Generate a bar chart representing death record completion time
  # by step.
  def bar_death_record_time_by_step
    verify_is_admin
    chart = StatisticsHelper.bar_death_record_time_by_step
    render html: chart.html_safe
  end

  # Generate a bar chart representing timeliness of death records completion
  # by a user versus the system average (for their workflow).
  def bar_average_completion
    chart = StatisticsHelper.bar_average_completion(current_user)
    render html: chart.html_safe
  end

  def pie_death_record_ages_by_range
    chart = StatisticsHelper.pie_death_record_ages_by_range(current_user)
    render html: chart.html_safe
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
