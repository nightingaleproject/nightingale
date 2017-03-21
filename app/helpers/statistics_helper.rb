# Statistics Module for helping with building charts
module StatisticsHelper
  require 'chartkick'
  extend Chartkick::Helper

  #############################################################################
  # Methods for generating line charts
  #############################################################################

  # Generate a line chart representing all death records created over the
  # given start date to end date.
  def self.line_death_records_created(start_date, end_date)
    # Grab data
    data = DeathRecord.all
    # Create line chart
    StatisticsHelper.generate_date_line_chart(start_date, end_date, data, 'Death Records Created')
  end

  # Generate a line chart representing all death records completions over the
  # given start date to end date.
  def self.line_death_records_completed(start_date, end_date)
    # Grab data
    data = DeathRecord.where.not(time_registered: nil)
    # Create line chart
    StatisticsHelper.generate_date_line_chart(start_date, end_date, data, 'Death Records Completed', 'time_registered')
  end

  # Generate a line chart representing new user sign ups over the
  # given start date to end date.
  def self.line_users_created(start_date, end_date)
    # Grab data
    data = User.all
    # Create line chart
    StatisticsHelper.generate_date_line_chart(start_date, end_date, data, 'Users Created')
  end

  # Generate a line chart representing all user sign ins over the
  # given start date to end date.
  def self.line_user_sign_ins(start_date, end_date)
    # Grab data
    data = Audited::Audit.where("to_tsvector('english', audited_changes) @@ to_tsquery(?)", 'current_sign_in_at').where(action: :update)
    # Create line chart
    StatisticsHelper.generate_date_line_chart(start_date, end_date, data, 'User Sign Ins')
  end

  # Builds data for generating line charts based on time periods.
  def self.generate_date_line_chart_data(data, start_date, end_date, field)
    opts = [field, { range: start_date..end_date, format: '%d %b' }]
    method_name = :group_by_day
    if end_date - (1.year + 2.days) > start_date
      opts[1][:format] = '%Y'
      method_name = :group_by_year
    elsif end_date - (3.months + 2.days) > start_date
      opts[1][:format] = '%b %Y'
      method_name = :group_by_month
    end
    results = data.send(method_name, *opts).count
    [{ name: 'Count', data: results }]
  end

  # Builds options for generating line charts based on time periods.
  def self.build_date_line_chart_options(title, start_date, end_date)
    {
      discrete: true,
      library: {
        title: { text: title, x: -20 },
        subtitle: { text: "from #{DatetimeHelper.pretty_datetime(start_date)} to #{DatetimeHelper.pretty_datetime(end_date)}", x: -20 },
        yAxis: {
          title: {
            text: 'Count'
          }
        },
        tooltip: {
          valueSuffix: ' item(s)'
        },
        credits: {
          enabled: false
        }
      }
    }
  end

  # Renders a date based line chart based on the given parameters.
  def self.generate_date_line_chart(start_date, end_date, data, title, field = 'created_at')
    start_date, end_date = StatisticsHelper.format_start_end_dates(start_date, end_date)
    options = StatisticsHelper.build_date_line_chart_options(title, start_date, end_date)
    line_chart StatisticsHelper.generate_date_line_chart_data(data, start_date, end_date, field), options
  end

  #############################################################################
  # Methods for generating bar charts
  #############################################################################

  # Generate a bar chart representing timeliness of death records completion
  # by a user versus the system average (for their workflow).
  def self.bar_average_completion(user)
    user_average = StatisticsHelper.average_time_by_workflow(user.id, true)
    system_average = StatisticsHelper.average_time_by_workflow(user.id, false)
    averages = {}
    averages['My Average'] = user_average
    averages['Jurisdiction Average'] = system_average
    if averages['Your Average'] != 0 && averages['Jurisdiction Average'] != 0
      return bar_chart averages, label: 'Minutes', id: 'user-record-step-chart', height: '220px', ytitle: 'Time (minutes)'
    else
      return 'You have not completed any death records yet.'
    end
  end

  # Generate a bar chart representing death record completion time
  # by step.
  def self.bar_death_record_time_by_step
    bar_chart StatisticsHelper.average_time_by_step(nil), label: 'Minutes', title: 'Death Record Completion by Step', id: 'record-step-chart', ytitle: 'Time (minutes)'
  end

  #############################################################################
  # Methods for generating pie charts
  #############################################################################

  # Generate a pie chart representing death records by their current
  # step.
  def self.pie_death_records_by_step
    death_records = DeathRecord.group(:record_status).count
    if death_records.key?('wicked_finish')
      death_records['registrar'] = death_records.delete 'wicked_finish'
    end
    titleize_hash = {}
    death_records.each do |step, count|
      titleize_hash[step.titleize] = count
    end
    pie_chart titleize_hash, id: 'record-count-chart', title: 'Death Records by Current Step'
  end

  # Generate a pie chart representing death record ages by range.
  def self.pie_death_record_ages_by_range(user)
    death_records_lt_5 = DeathRecord.where(owner_id: user.id).where('created_at > ?', 5.days.ago).count
    death_records_gt_10 = DeathRecord.where(owner_id: user.id).where('created_at > ?', 10.days.ago).count - death_records_lt_5
    death_records_5_to_10 = DeathRecord.where(owner_id: user.id).count - death_records_lt_5 - death_records_gt_10
    ages = {}
    ages['Less than 5 days'] = death_records_lt_5 unless death_records_lt_5 == 0
    ages['5 to 10 days'] = death_records_lt_5 unless death_records_5_to_10 == 0
    ages['More than 10 days'] = death_records_lt_5 unless death_records_gt_10 == 0
    if ages.count > 0
      return pie_chart ages, id: 'death-record-ages-by-range', height: '220px'
    else
      return 'You currently have no open records.'
    end
  end

  #############################################################################
  # General helper methods
  #############################################################################

  # If one of the dates is empty, we populate it with a default value.
  # If the date is not empty, convert it to datetime (because initially it is a string).
  # Lastly, we swap the date if the end date comes after the start date.
  def self.format_start_end_dates(start_date, end_date)
    adjusted_start_date = start_date.nil? || start_date.empty? ? 1.month.ago.midnight : start_date.to_datetime.midnight
    adjusted_end_date = end_date.nil? || end_date.empty? ? Time.current.at_end_of_day : end_date.to_datetime.at_end_of_day
    adjusted_start_date, adjusted_end_date = adjusted_end_date, adjusted_start_date if adjusted_end_date < adjusted_start_date
    [adjusted_start_date, adjusted_end_date]
  end

  # Calculates the average completion time per step in the workflow.
  # Specify a user_id in order to scope calculation to that user's steps.
  # Set user_avg to true if the calculation should be scoped to a single user.
  def self.average_time_by_step(user_id = nil, user_avg = false)
    # Figure out the given user's role (could potentialy be nothing)
    user = User.find(user_id) unless user_id.nil?
    user_role = user.roles.first.name unless user.nil? || user.roles.first.nil?
    # Figure out what steps to consider
    steps = if user_role.nil?
              StepsHelper.all_steps
            else
              StepsHelper.steps_for_role(user_role)
            end
    # Take step averages; scoped for either system or user specific
    averages = {}
    steps.each do |step|
      averages[step] = if !user.nil? && user_avg
                         StepTimeTaken.where(step: step, user_id: user_id).average(:time_taken).to_f.round(2)
                       else
                         StepTimeTaken.where(step: step).average(:time_taken).to_f.round(2)
                       end
    end
    # Replace wicked_finish with registrar
    averages['registrar'] = averages.delete('wicked_finish') if averages.key?('wicked_finish')
    averages
  end

  # Calculates the average completion time for an entire workflow.
  # Specify a user_id in order to scope calculation to that user's workflow.
  # Set user_avg to true if the calculation should be scoped to a single user.
  def self.average_time_by_workflow(user_id = nil, user_avg = false)
    averages = StatisticsHelper.average_time_by_step(user_id, user_avg)
    # Return zero if any of the steps were zero (workflow not yet completed)
    return 0 if averages.values.any? { |value| value == 0 }
    average = averages.values.inject(0) { |a, e| a + e }.round(2)
    average = 0 if average.nan?
    average
  end
end
