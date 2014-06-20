module Trip::PickupTime
  extend ActiveSupport::Concern

  included do
    attr_accessor :outbound_trip_date, :outbound_arrive_depart, :outbound_trip_time
    validates :outbound_trip_date, :presence => true
    validates :outbound_trip_time, :presence => true

    # check date and time format and ensure trips are not being planned in the past
    validate :validate_date
    validate :validate_time
    validate :datetime_cannot_be_before_now
  end

  # Returns the trip date and time as a DateTime class
  def trip_datetime
    begin
      return Chronic.parse([outbound_trip_date, outbound_trip_time].join(' '))
      # return DateTime.strptime([trip_date, trip_time, DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "trip_datetime #{outbound_trip_date} #{outbound_trip_time}"
      Rails.logger.warn e.message
      # return nil
      raise e
    end
  end

  def self.defaults trip
    travel_date = TripsSupport.default_trip_time

    trip.trip_date = travel_date.strftime(TripsSupport::TRIP_DATE_FORMAT_STRING)
    trip.trip_time = travel_date.strftime(TripsSupport::TRIP_TIME_FORMAT_STRING)
    trip
  end

protected

  # Validation. Ensure that the user is planning a trip for the future.
  def datetime_cannot_be_before_now
    return true if trip_datetime.nil?
    if trip_datetime < Date.today
      errors.add(:outbound_trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
      return false
    elsif trip_datetime < Time.current
      errors.add(:outbound_trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
      return false
    end
    true
  end

  # Validation. Check that the date is well formatted and can be coerced into a date
  def validate_date
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      d = Date.strptime(@outbound_trip_date, '%m/%d/%Y')
    rescue Exception => e
      puts e
      errors.add(:outbound_trip_date, I18n.translate(:date_wrong_format))
    end
  end

  # Validation. Check that the trip time is well formatted and can be coerced into a time
  def validate_time
    begin
      time = Time.strptime(outbound_trip_time, "%H:%M %p")
    rescue Exception => e
      puts e
      errors.add(:outbound_trip_time, I18n.translate(:time_wrong_format))
    end
  end
end
