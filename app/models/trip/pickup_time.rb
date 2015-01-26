module Trip::PickupTime
  extend ActiveSupport::Concern

  included do
    attr_accessor :outbound_trip_date, :outbound_arrive_depart, :outbound_trip_time
    validates :outbound_trip_date, :presence => true
    validates :outbound_trip_time, :presence => true

    # check date and time format and ensure trips are not being planned in the past
    validate :validate_date
    validate :validate_time
  end

  def self.defaults trip
    travel_date = TripsSupport.default_trip_time

    trip.outbound_trip_date = travel_date.strftime(TripsSupport::TRIP_DATE_FORMAT_STRING)
    trip.outbound_trip_time = travel_date.strftime(TripsSupport::TRIP_TIME_FORMAT_STRING)
    trip
  end

protected

  # Validation. Check that the date is well formatted and can be coerced into a date
  def validate_date
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      if user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
        d = Date.strptime(@outbound_trip_date, '%Y-%m-%d')
      else
        d = Date.strptime(@outbound_trip_date, '%m/%d/%Y')
      end
    rescue Exception => e
      puts e
      errors.add(:outbound_trip_date, I18n.translate(:date_wrong_format))
    end
  end

  # Validation. Check that the trip time is well formatted and can be coerced into a time
  def validate_time
    begin
      if user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
        time = Time.strptime(outbound_trip_time, "%H:%M")
      else
        time = Time.strptime(outbound_trip_time, "%H:%M %p")
      end
    rescue Exception => e
      puts e
      errors.add(:outbound_trip_time, I18n.translate(:time_wrong_format))
    end
  end
end
