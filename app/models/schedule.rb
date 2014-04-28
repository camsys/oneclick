class Schedule < ActiveRecord::Base

  #associations
  belongs_to :service

  # attr_accessible :service, :service_id, :start_time, :end_time, :day_of_week, :start_seconds, :end_seconds
  validates :day_of_week, :presence => true
  # 0=Sunday
  validates_numericality_of :day_of_week, greater_than_or_equal_to: 0,
    less_than_or_equal_to: 6

  def start_string
    human_readable(start_seconds)
  end
  alias_method :start_time, :start_string
  
  def end_string
    human_readable(end_seconds)
  end
  alias_method :end_time, :end_string
  
  def human_readable(seconds)
    return '' if seconds.nil?
    
    hour = seconds/3600
    minute = (seconds - (hour*3600))/60
    ampm = 'AM'
    if hour > 12
      hour -= 12
      ampm = 'PM'
    end
    if hour == 12
      ampm = 'PM'
    end
    if hour == 0
      hour = 12
    end
    minute = "%.2d" % minute
    hour.to_s + ':' + minute.to_s + ' ' + ampm

  end

  def start_time= t
    self.start_seconds = Time.parse(t).seconds_since_midnight
  end

  def end_time= t
    self.end_seconds = Time.parse(t).seconds_since_midnight
  end

  # simplify debugging
  def to_s
    "<#{day_of_week}: #{start_string} - #{end_string}>"
  end
  
end
