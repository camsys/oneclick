class Trip::ValidationWrapper::PickupTime < Trip::ValidationWrapper::Base
  include Trip::PickupTime

  def as_json *args
    return_time = trip_datetime + TripsSupport::DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    @default_return_trip_time = return_time.strftime(TripsSupport::TRIP_TIME_FORMAT_STRING)
    @default_return_trip_date = return_time.strftime('%m/%d/%Y')
    super
  end
end
