require 'chronic'

class TripProxy < Proxy

  attr_accessor :from_place, :to_place, :trip_date, :arrive_depart, :trip_time, :model_name, :traveler, :trip_purpose_id
  attr_accessor :from_place_results, :to_place_results
  attr_accessor :from_place_selected, :to_place_selected
  attr_accessor :from_place_selected_type, :to_place_selected_type
  attr_accessor :mode, :id
  validates :from_place, :presence => true
  validates :to_place, :presence => true
  validates :trip_date, :presence => true
  validates :trip_time, :presence => true
  validates :trip_purpose_id, :presence => true

  validate :validate_date
  validate :validate_time
  
  validate :datetime_cannot_be_before_now
  
  def initialize(attrs = {})
    super
    @from_place_results = []
    @to_place_results = []
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  def trip_datetime
    begin
      return DateTime.strptime([trip_date, trip_time, DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "write_trip_datetime #{trip_date} #{trip_time}"
      Rails.logger.warn e.message
      return nil
    end
  end

protected

  def datetime_cannot_be_before_now
    return true if trip_datetime.nil?
    if trip_datetime < Date.today
      errors.add(:trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
      return false
    elsif trip_datetime < Time.current
      errors.add(:trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
      return false
    end
    true
  end
        
  def validate_date
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      d = Chronic.parse(@trip_date).to_date
    rescue Exception => e
      errors.add(:trip_date, I18n.translate(:date_wrong_format))
    end
  end

  def validate_time
    begin
      Time.strptime(@trip_time, "%H:%M %p")
    rescue Exception => e
      errors.add(:trip_time, I18n.translate(:time_wrong_format))
    end
  end
              
end