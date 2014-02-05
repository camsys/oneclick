class Trip::ValidationWrapper::Purpose < Trip::ValidationWrapper::Base
  include Trip::Purpose

  def as_json *args
    @trip_purpose = TripPurpose.find(trip_purpose_id)
    super
  end
end
