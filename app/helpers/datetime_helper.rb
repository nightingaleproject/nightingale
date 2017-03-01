# Datetime Helper module
module DatetimeHelper
  def self.pretty_datetime(datetime)
    return '' if datetime.nil?
    datetime.localtime.strftime('%b %d, %Y %I:%M %p')
  end

  def self.pretty_date(date)
    return '' if date.nil?
    date.localtime.strftime('%b %d, %Y')
  end

  def self.pretty_time(time)
    return '' if time.nil?
    time.localtime.strftime('%I:%M %p')
  end
end
