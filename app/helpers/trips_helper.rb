module TripsHelper
  include ApplicationHelper
  include ServiceAdapters::RideshareAdapter

  def get_alt_button_text(itinerary, button_action)
    # TODO This may need fixing mode.name/code
    # TODO Also, this code is duplicated in planned_trips_helper.rb
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
      'col-sm-6'
    else
      (trip.outbound_part.selected? ? 'col-sm-3' : 'col-sm-12')
    end
  end

  def send_trip_by_email_list traveler, is_assisting
    list = []
    list << ["Traveler: " + traveler.email + " (" + traveler.name + ")", traveler.email] if is_assisting
    current_user.buddies.confirmed.each do |buddy|
      list << ["Buddy: " + buddy.email + " (" + buddy.name + ")", buddy.email]
    end
    list << ['Me: '+  current_user.email, current_user.email]
    list
  end

  ACTIONS_TO_TABS = HashWithIndifferentAccess.new(
    trips_new: :trip,
    trips_edit: :trip,
    trips_create: :trip,
    characteristics_new: :options,
    trips_show: :review,
    trips_plan: :plan,
    )

  TABS_TO_ACTIONS = ACTIONS_TO_TABS.invert

  TABS = [:trip, :options, :review, :plan]

  def visited_tabs
    TABS.slice(0, TABS.index(ACTIONS_TO_TABS[controller_and_action]))
  end

  def active_tab
    ACTIONS_TO_TABS[controller_and_action]
  end

  def breadcrumb_class tab
    if tab==active_tab
      'current-page'
    else
      'next-page'
    end
  end

  def breadcrumb_tab_navigable tab
    visited_tabs.include? tab
  end

  def breadcrumb_path tab
    case tab
    when :trip
      edit_user_trip_path(@traveler, @trip)
    when :options
      new_user_trip_characteristic_path(@traveler, @trip)
    when :review
      user_trip_path(@traveler, @trip)
    when :plan
      '/trip'
    else
      raise "unhandled tab #{tab}"
    end
  end

end
