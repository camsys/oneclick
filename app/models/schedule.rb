class Schedule < ActiveRecord::Base

  #associations
  belongs_to :service

  attr_accessible :service, :service_id, :start_time, :end_time, :day_of_week, :start_seconds, :end_seconds

  def start_string
    human_readable(start_seconds)
  end

  def end_string
    human_readable(end_seconds)
  end

  def human_readable(seconds)
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

end
