class Trip::ValidationWrapper::Purpose < Trip::ValidationWrapper::Base
  include Trip::Purpose

  def as_json *args
    @trip_purpose = TripPurpose.find(trip_purpose_id)
    @trip_purpose_name = TranslationEngine.translate_text(@trip_purpose.name)
    super
  end
end
