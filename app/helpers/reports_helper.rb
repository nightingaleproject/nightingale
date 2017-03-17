# Reports Helper module
module ReportsHelper
  # Compares time of creation to the time of completion for each death record. Returns the mean.
  def self.calculate_average_time_for_death_records
    calculatable_records = []
    # Grab all records of completed death records.
    completed_death_records = DeathRecord.where.not(time_registered: nil)
    if !completed_death_records.blank?
      completed_death_records.each do |record|
        # Subtract started time from the completed time to get the difference in seconds.
        calculatable_records << record.time_registered - record.created_at
      end

      # Use the array of differences and find the average difference.
      mean_in_seconds = calculatable_records.inject(0.0) { |a, e| a + e } / calculatable_records.size
      ReportsHelper.seconds_to_string(mean_in_seconds)
    else
      'No Completed Records'
    end
  end

  # Convert time from seconds to properly formatted time. 129 :=> 2 minutes, 9 seconds
  def self.seconds_to_string(s)
    s = s.to_i.abs
    # d = days, h = hours, m = minutes, s = seconds
    m = (s / 60).floor
    s = s % 60
    h = (m / 60).floor
    m = m % 60
    d = (h / 24).floor
    h = h % 24

    output = "#{s} second#{ReportsHelper.pluralize(s)}" if s > 0
    output = "#{m} minute#{ReportsHelper.pluralize(m)}, #{s} second#{ReportsHelper.pluralize(s)}" if m > 0
    output = "#{h} hour#{ReportsHelper.pluralize(h)}, #{m} minute#{ReportsHelper.pluralize(m)}, #{s} second#{ReportsHelper.pluralize(s)}" if h > 0
    output = "#{d} day#{ReportsHelper.pluralize(d)}, #{h} hour#{ReportsHelper.pluralize(h)}, #{m} minute#{ReportsHelper.pluralize(m)}, #{s} second#{ReportsHelper.pluralize(s)}" if d > 0

    output
  end

  # Pluralize a word (return an 's' if the given number is not 1)
  def self.pluralize(number)
    return 's' unless number == 1
    ''
  end
end
