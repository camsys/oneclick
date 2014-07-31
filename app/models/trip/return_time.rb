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
    validate :datetime_cannot_be_before_now

  end

  # Returns the return trip date and time as a DateTime class. If the round-trip is not defined
  # we return nil
  def return_trip_datetime
    if is_round_trip != "1"
      return nil
    end

    begin
      unless return_trip_date.nil?      
        return Chronic.parse([return_trip_date, return_trip_time].join(' '))
      else
        return Chronic.parse(return_trip_time)
      end
      # return DateTime.strptime([return_trip_date, return_trip_time, DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "return_trip_datetime #{trip_date} #{trip_time}"
      Rails.logger.warn e.message
      return nil
    end
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

  # TODO duplication, this shoud be factored out of here and pickup_time.rb
  # Validation. Ensure that the user is planning a trip for the future.
  def datetime_cannot_be_before_now
    return true if return_trip_datetime.nil?
    if return_trip_datetime < Date.today
      errors.add(:return_trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
      return false
    elsif return_trip_datetime < Time.current
      errors.add(:return_trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
      return false
    end
    true
  end

  # Validation. Check that the return trip time is well formatted and after the trip time
  def validate_return_trip_time
    return_dt = return_trip_datetime
    ott = outbound_trip_time.respond_to?(:to_datetime) ? outbound_trip_time : Chronic.parse(outbound_trip_time)
    ott = defined?(trip_datetime).nil? ? ott : trip_datetime
    if return_dt && (return_dt <= ott)
      errors.add(:return_trip_time, I18n.translate(:return_trip_time_before_start))
    end
  end

  def validate_date
    return true if is_round_trip != "1" # if a trip is planned for one-way, the date for the return has to be valid
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      d = Date.strptime(@return_trip_date, '%m/%d/%Y')
    rescue Exception => e
      puts e
      errors.add(:return_trip_date, I18n.translate(:date_wrong_format))
    end
  end

  # Validation. Check that the trip time is well formatted and can be coerced into a time
  def validate_time
    return true if is_round_trip != "1" # if a trip is planned for one-way, the time for the return has to be valid
    begin
      time = Time.strptime(return_trip_time, "%H:%M %p")
    rescue Exception => e
      puts e
      errors.add(:return_trip_time, I18n.translate(:time_wrong_format))
    end
  end
end
