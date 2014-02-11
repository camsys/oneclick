class Trip::ValidationWrapper::PickupTime < Trip::ValidationWrapper::Base
  include Trip::PickupTime

  def as_json *args
    @trip_datetime = trip_datetime
    @return_trip_time = (trip_datetime + TripsSupport::DEFAULT_RETURN_TRIP_DELAY_MINS.minutes).strftime(TripsSupport::TRIP_TIME_FORMAT_STRING)
    super
  end
end
