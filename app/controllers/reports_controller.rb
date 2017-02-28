class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :verify_is_admin

  def index
     @audits = Audited::Audit.all.order(created_at: :desc)
     @mean = calculate_average_time_for_death_records
     @death_records_by_step = death_records_by_current_step
     @average_times = average_time_by_step
  end

  private

  def death_records_by_current_step()
    death_records = DeathRecord.group(:record_status).count

    death_records["registrar"] = death_records.delete "wicked_finish"

    # Titleize all keys
    titleize_hash = {}
    death_records.each do |step, count|
      titleize_hash[step.titleize] = count
    end

    titleize_hash
  end

  # Returns a hash of average time death records are in each step (in minutes).
  # NOTE: We replace "wicked_finish" with "registrar". (Wicked Finish is an automatic "last_step", which comes from the wicked Gem)
  # Ex: { "medical" => 1029, "identity" => 101, "registrar" => 2 }
  def average_time_by_step
    step_times_hash = {} # Will be a hash of arrays. "medical" => [12, 144, 155]
    death_records = DeathRecord.all
    death_records.each do |death_record|
      previous_step_time = 0
      # Grab all audit records that involve "record status" change. Sort by "created_at"
      @results = Audited::Audit.where("to_tsvector('english', audited_changes) @@ to_tsquery(?)", "record_status").where(auditable_id: death_record.id, auditable_type: :DeathRecord).order(created_at: :asc)

      @results.each_with_index do |result_record, index|
        record_status_change = result_record.audited_changes['record_status'] # This returns either a string of the current step. Or an array showing ["old_step", "new_step"]

        if index == 0 && @results.count == 1 # First item (which is in string form) and the only item
          (step_times_hash[record_status_change] ||= []) << Time.now - result_record.created_at
        elsif index == 0 # First item in results but not last
          previous_step_time = result_record.created_at
        else
          (step_times_hash[record_status_change[0]] ||= []) << result_record.created_at - previous_step_time
          previous_step_time = result_record.created_at

          if index == (@results.length - 1) # If last item in results.
            time_to_use = 0
            if death_record.time_registered.blank?
              time_to_use = Time.now
            else
              time_to_use = death_record.time_registered
            end
            (step_times_hash[record_status_change[1]] ||= []) << time_to_use - result_record.created_at
          end
        end
      end
    end

    # Iterate over each of the arrays by step and calculate the mean time a record is in the given step.
    average_scores = {}
    step_times_hash.each do |step, step_times|
      average_scores[step] = (step_times.inject(0.0) { |sum, el| sum + el } / step_times.size) / 60
    end

    # Replace 'wicked_finish' with 'registrar'
    average_scores["registrar"] = average_scores.delete "wicked_finish"

    # Titleize all keys
    titleize_hash = {}
    average_scores.each do |step, step_times|
      titleize_hash[step.titleize] = step_times.to_i.abs
    end

    titleize_hash
  end

  # Compares time of creation to the time of completion for each death record. Returns the mean.
  def calculate_average_time_for_death_records
    calculatable_records = []
    # Grab all records of completed death records.
    completed_death_records = DeathRecord.where.not(time_registered: nil)
    completed_death_records.each do |record|
      # Subtract started time from the completed time to get the difference in seconds.
      calculatable_records << record.time_registered - record.created_at
    end

    # Use the array of differences and find the average difference.
    mean_in_seconds = calculatable_records.inject(0.0) { |sum, el| sum + el } / calculatable_records.size
    mean = seconds_to_string(mean_in_seconds)
  end

   # Convert time from seconds to properly formatted time. 129 :=> 2 minutes, 9 seconds
   def seconds_to_string(s)
    s = s.to_i.abs
    # d = days, h = hours, m = minutes, s = seconds
    m = (s / 60).floor
    s = s % 60
    h = (m / 60).floor
    m = m % 60
    d = (h / 24).floor
    h = h % 24

    output = "#{s} second#{pluralize(s)}" if (s > 0)
    output = "#{m} minute#{pluralize(m)}, #{s} second#{pluralize(s)}" if (m > 0)
    output = "#{h} hour#{pluralize(h)}, #{m} minute#{pluralize(m)}, #{s} second#{pluralize(s)}" if (h > 0)
    output = "#{d} day#{pluralize(d)}, #{h} hour#{pluralize(h)}, #{m} minute#{pluralize(m)}, #{s} second#{pluralize(s)}" if (d > 0)

    return output
  end

  def pluralize number
    return "s" unless number == 1
    return ""
  end

  def verify_is_admin
    (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
