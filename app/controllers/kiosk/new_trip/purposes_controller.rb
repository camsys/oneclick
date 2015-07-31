class Kiosk::NewTrip::PurposesController < Kiosk::NewTrip::BaseController
  def show
    @trip_purposes = if @traveler.user_profile.user_services.count > 0
      eh = EcolaneHelpers.new
      eh.get_trip_purposes_from_traveler(@traveler).map{|p| {name: p, id: p}}
    else
      TripPurpose.all.map do |p|
        translated = TranslationEngine.translate_text(p.name)

        name = if translated =~ /^Translation not found:/
          p.name.sub(/_name$/, '')
        else
          translated
        end

        {
          name: name,
          id: p.id
        }
      end
    end

    super
  end

end
