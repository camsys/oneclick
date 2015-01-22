module Trip::ReturnTime
  extend ActiveSupport::Concern

  included do
    # For round trips. :return_trip_time is the time to start the return trip back the
    # start place
    attr_accessor :is_round_trip, :return_trip_time, :return_arrive_depart, :return_trip_date

    # ensure that a valid return time is set if a return trip is selected
    validate :return_trip_date, :presence => true
    validate :return_trip_time, :presence => true
    validate :validate_return_trip_time

    validate :validate_date
    validate :validate_time
  end

  # Returns the return trip date and time as a DateTime class. If the round-trip is not defined
  # we return nil
  def return_trip_datetime
    return nil if is_round_trip != "1"
    parse_time_and_fields('return_trip')
  end

  def outbound_trip_datetime
    parse_time_and_fields('outbound_trip')
  end

  def self.defaults trip
    travel_date = if respond_to?(:trip_time) && trip_time.present?
      trip_time
    else
      TripsSupport.default_trip_time
    end

    # default to a round trip. The default return trip time is set the the default trip time plus
    # a configurable interval
    return_trip_time = travel_date + TripsSupport::DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    trip.is_round_trip = "1"
    trip.return_trip_time = return_trip_time.strftime(TripsSupport::TRIP_TIME_FORMAT_STRING)
    trip
  end

protected

  # Validation. Check that the return trip time is well formatted and after the trip time
  def validate_return_trip_time
    if return_trip_datetime && (return_trip_datetime <= outbound_trip_datetime)
      errors.add(:return_trip_time, I18n.translate(:return_trip_time_before_start))
    end
  end

  def validate_date
    return true if is_round_trip != "1" # if a trip is planned for one-way, the date for the return has to be valid
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      if user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
        d = Date.strptime(return_trip_date, '%Y-%m-%d')
      else
        d = Date.strptime(return_trip_date, '%m/%d/%Y')
      end
    rescue Exception => e
      puts e
      errors.add(:return_trip_date, I18n.translate(:date_wrong_format))
    end
  end

  # Validation. Check that the trip time is well formatted and can be coerced into a time
  def validate_time
    return true if is_round_trip != "1" # if a trip is planned for one-way, the time for the return has to be valid
    begin
      if user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
        time = Time.strptime(return_trip_time, "%H:%M")
      else
        time = Time.strptime(return_trip_time, "%H:%M %p")
      end
    rescue Exception => e
      puts e
      errors.add(:return_trip_time, I18n.translate(:time_wrong_format))
    end
  end

  def parse_time_and_fields prefix
    date_field = "#{prefix}_date"
    time_field = "#{prefix}_time"

    begin
      unless send(date_field).nil?
        return Chronic.parse([send(date_field), send(time_field)].join(' '))
      else
        return Chronic.parse(send(time_field))
      end
      # return DateTime.strptime([send(date_field), send(time_field), DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "#{prefix}_datetime #{trip_date} #{trip_time}"
      Rails.logger.warn e.message
      return nil
    end
  end
end
