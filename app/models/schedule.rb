class Schedule < ActiveRecord::Base

  #associations
  belongs_to :service

  # attr_accessible :service, :service_id, :start_time, :end_time, :day_of_week, :start_seconds, :end_seconds
  # for rspec
  attr_reader :start_time_present, :start_time_valid, :end_time_present, :end_time_valid

  validate :times_valid_present_and_start_before_end
  
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

  # Handle validation
  @start_time_valid = false      
  @end_time_valid = false      
  @start_time_present = false
  @end_time_present = false

  def start_time= t
    self.start_seconds = nil
    if t.blank?
      @start_time_present = false
      @start_time_valid = false      
    else
      @start_time_present = true
      begin
        self.start_seconds = Time.parse(t).seconds_since_midnight
        @start_time_valid = true
      rescue
        @start_time_valid = false
      end
    end
  end

  def end_time= t
    self.end_seconds = nil
    if t.blank?
      @end_time_present = false
      @end_time_valid = false      
    else
      @end_time_present = true
      begin
        self.end_seconds = Time.parse(t).seconds_since_midnight
        @end_time_valid = true
      rescue
        @end_time_valid = false      
      end
    end
    
  end

  # simplify debugging
  def to_s
    "<#{day_of_week}: #{start_string} - #{end_string}>"
  end

protected
  
  def times_valid_present_and_start_before_end
    errors.add(:"#{day_of_week}start_time", I18n.t(:presence_msg)) if !@start_time_present && @end_time_present
    errors.add(:"#{day_of_week}end_time", I18n.t(:presence_msg)) if !@end_time_present && @start_time_present
    errors.add(:"#{day_of_week}start_time", I18n.t(:valid_time_msg)) if @start_time_present && !@start_time_valid
    errors.add :"#{day_of_week}end_time", I18n.t(:valid_time_msg) if @end_time_present && !@end_time_valid
      
    if @start_time_valid && @end_time_valid
      errors.add(:"#{day_of_week}start_time", I18n.t(:before_msg) + I18n.t(:end_time)) if (start_seconds > end_seconds)

    end
    puts pp errors.inspect
  end
  
end
