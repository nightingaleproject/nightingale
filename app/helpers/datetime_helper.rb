# Datetime Helper module
module DatetimeHelper
  def self.pretty_datetime(datetime)
    unless datetime.nil?
      return datetime.localtime.strftime('%b %d, %Y %I:%M %p')
    else
      return ''
    end
  end
  
  def self.pretty_date(date)
    unless date.nil?
      return date.localtime.strftime('%b %d, %Y')
    else
      return ''
    end
  end
  
  def self.pretty_time(time)
    unless time.nil?
      return time.localtime.strftime('%I:%M %p')
    else
      return ''
    end
  end
end
