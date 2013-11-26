module TripsHelper
  include ApplicationHelper
  include ServiceAdapters::RideshareAdapter

  def get_alt_button_text(itinerary, button_action)
    "#{button_action.capitalize} #{itinerary.mode.name.downcase} option."
  end

  def trip_detail_header_by_mode itinerary
    if itinerary.mode=='rideshare'
      'trip_detail_header_rideshare'
    else
      'trip_summary_header'
    end
  end  

  def rideshare_external_link itinerary
    service_url + '?' + YAML.load(itinerary.external_info).to_query
  end

  def round_trip trip
    trip.is_return_trip ? t(:round_trip) : t(:one_way)
  end

  def depart_arrive trip_part
    trip_part.is_depart ? t(:departing_at) : t(:arriving_by)
  end

end
