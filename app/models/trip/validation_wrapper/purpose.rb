class Trip::ValidationWrapper::Purpose < Trip::ValidationWrapper::Base
  include Trip::Purpose

  def as_json *args
    unless trip_purpose_raw
      @trip_purpose = TripPurpose.find(trip_purpose_id)

      @trip_purpose_name = if (translated = TranslationEngine.translate_text(@trip_purpose.name)) =~ /^Translation not found:/
        @trip_purpose.name.sub(/_name$/, '')
      else
        translated
      end
    end

    super
  end
end
