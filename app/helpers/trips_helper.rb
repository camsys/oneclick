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

  def outbound_itineraries show_hidden
    itineraries(show_hidden, @trip.trip_parts.first)
  end

  def return_itineraries show_hidden
    itineraries(show_hidden, @trip.trip_parts.last)
  end

  def itineraries show_hidden, trip_part
    # (show_hidden.nil? ? trip_part.valid_itineraries.with_mode : trip_part.itineraries.with_mode).order('match_score')
    t = trip_part.itineraries.valid
    (show_hidden.nil? ? t.visible : t).order('match_score')
  end

  def itinerary_thumbnail_class itinerary
    itinerary.selected? ? 'itinerary_thumbnail_selected' : ''
  end

  def dialog_content_class trip_part
    case trip_part.max_notes_count
    when 0
      ''
    when 1
      'one-note'
    when 2
      'two-notes'
    else
      'three-notes'
    end
  end

  def outbound_section_class trip
    if trip.both_parts_selected?
      'span6'
    else
      (trip.outbound_part.selected? ? 'span3' : 'span12')
    end
  end

end
