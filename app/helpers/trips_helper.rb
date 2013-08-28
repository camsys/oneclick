module TripsHelper
  include ServiceAdapters::RideshareAdapter

  def trip_detail_header_by_mode itinerary
    if itinerary.mode=='rideshare'
      'trip_detail_header_rideshare'
    else
      'trip_summary_header'
    end
  end  

  def rideshare_external_link itinerary
    service_url + '?' + create_rideshare_query(itinerary.trip.from_place,
      itinerary.trip.to_place, itinerary.trip.trip_datetime).to_query
  end

end
