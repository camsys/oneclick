module TripsHelper
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

end
