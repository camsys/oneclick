class ItinerarySerializer < ActiveModel::Serializer
  attributes :id, :missing_information, :mode, :mode_name, :service_name, :contact_information,
    :cost, :duration, :transfers, :start_time, :end_time, :legs

  def mode
    object.mode.code rescue nil
  end

  def mode_name
    object.mode.name rescue nil    
  end

  def missing_information
    es = EligibilityService.new
    es.get_service_itinerary(object.service, object.trip_part.trip.user.user_profile, object.trip_part, :missing_info)
  end

  def contact_information
    object.service.contact_information rescue nil
  end

  def cost
    fare = object.service.fare_structures.first rescue nil
    if fare.nil?
      {cost: nil, comments: 'Unknown'} # TODO I18n
    else
      {cost: fare.base, comments: fare.desc}
    end
  end

  def legs
    legs = object.get_legs
    legs.collect do |leg|
      {
        type: leg.mode,
        description: I18n.t(:to) + ' '+ leg.end_place.name,
        start_time: leg.start_time,
        end_time: leg.end_time,
        start_place: "#{leg.start_place.lat},#{leg.start_place.lon}",
        end_place: "#{leg.end_place.lat},#{leg.end_place.lon}",
      }
    end
  end

end
