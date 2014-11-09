class BookingCutOffTime < ActiveRecord::Base

  #associations
  belongs_to :service

  # attr_accessible :service, :service_id, :day_of_week, :cut_off_time, :cut_off_seconds
  # for rspec
  attr_reader :cut_off_time_present, :cut_off_time_valid

  validate :times_valid_present

  validates :day_of_week, :presence => true
  # 0=Sunday
  validates_numericality_of :day_of_week, greater_than_or_equal_to: 0,
    less_than_or_equal_to: 6

  def cut_off_time_string
    human_readable(cut_off_seconds)
  end
  alias_method :cut_off_time, :cut_off_time_string

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
  @cut_off_time_valid = false
  @cut_off_time_present = false

  def cut_off_time= t
    self.cut_off_seconds = nil
    if t.blank?
      @cut_off_time_present = false
      @cut_off_time_valid = false
    else
      @cut_off_time_present = true
      begin
        self.cut_off_seconds = Time.parse(t).seconds_since_midnight
        @cut_off_time_valid = true
      rescue
        @cut_off_time_valid = false
      end
    end
  end


  # simplify debugging
  def to_s
    "<#{day_of_week}: #{cut_off_time_string}>"
  end

protected

  def times_valid_present
    errors.add(:"#{day_of_week}cut_off_time", I18n.t(:presence_msg)) if !@cut_off_time_present
    errors.add(:"#{day_of_week}cut_off_time", I18n.t(:valid_time_msg)) if !@cut_off_time_valid
  end

end
