module Trip::ReturnTime
  extend ActiveSupport::Concern

  included do
    # For round trips. :return_trip_time is the time to start the return trip back the
    # start place
    attr_accessor :is_round_trip, :return_trip_time

    # ensure that a valid return time is set if a return trip is selected
    validate :validate_return_trip_time
  end

  # Returns the return trip date and time as a DateTime class. If the round-trip is not defined
  # we return nil
  def return_trip_datetime

    if is_round_trip != "1"
      return nil
    end

    begin
      return DateTime.strptime([trip_date, return_trip_time, DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "return_trip_datetime #{trip_date} #{trip_time}"
      Rails.logger.warn e.message
      return nil
    end
  end

protected

  # Validation. Check that the return trip time is well formatted and after the trip time
  def validate_return_trip_time

    if is_round_trip == "1"
      begin
        return_time = Time.strptime(@return_trip_time, "%H:%M %p")
        trip_time = Time.strptime(@trip_time, "%H:%M %p")
        if return_time < trip_time
          errors.add(:return_trip_time, I18n.translate(:return_trip_time_before_start))
        end
      rescue Exception => e
        puts e.to_s
        errors.add(:return_trip_time, I18n.translate(:time_wrong_format))
      end
     end
  end
end
