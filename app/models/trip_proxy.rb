class TripProxy < Proxy
  # User object for the traveler
  attr_accessor :traveler
  # Type of operation. Defined in TripController. One of NEW, EDIT, REPEAT
  attr_accessor :mode
  # Id of the trip being re-planned, edited, etc. Null if mode is NEW
  attr_accessor :id, :map_center
  attr_accessor :trip_options

  include TripsSupport
  include Trip::From
  include Trip::PickupTime
  include Trip::Purpose
  include Trip::ReturnTime
  include Trip::To
  include Trip::Modes

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    @modes_desired = @modes
    # Modify modes to reflect transit 
    # Using array select with side effects
    if (@modes)
      bus = rail = nil
      @modes = @modes.select do |mode|
        case mode
        when ""
          false
        when Mode.bus.code
          bus = mode
          false
        when Mode.rail.code
          rail = mode
          false
        when Mode.transit.code
          false
        else
          true
        end
      end
    end
    

    if (bus && rail)
      @modes << Mode.transit.code
    elsif (bus)
      @modes << bus
    elsif (rail)
      @modes << rail
    end
  end

  # creates a trip_proxy object from a trip. Note that this does not set the
  # trip id into the proxy as only edit functions need this.
  def self.create_from_trip(trip, attr = {})

    # get the trip parts for this trip
    trip_part = trip.trip_parts.first

    # initialize a trip proxy from this trip
    trip_proxy = TripProxy.new(attr)
    trip_proxy.traveler = @traveler
    trip_proxy.trip_purpose_id = trip.trip_purpose.id

    trip_proxy.outbound_arrive_depart = trip_part.is_depart
    trip_datetime = trip_part.trip_time
    trip_proxy.outbound_trip_date = trip_part.scheduled_date.strftime(TRIP_DATE_FORMAT_STRING)
    temp_time = trip_part.scheduled_time
    trip_proxy.outbound_trip_time = trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    Rails.logger.info "create_trip_proxy"
    Rails.logger.info "trip_part.scheduled_date #{trip_part.scheduled_date}"
    Rails.logger.info "trip_part.scheduled_time #{trip_part.scheduled_time}"
    Rails.logger.info "trip_proxy.outbound_trip_date #{trip_proxy.outbound_trip_date}"
    Rails.logger.info "trip_proxy.outbound_trip_time #{trip_proxy.outbound_trip_time}"

    # Check for return trips
    if trip.trip_parts.count > 1
      last_trip_part = trip.trip_parts.last
      trip_proxy.is_round_trip = last_trip_part.is_return_trip ? "1" : "0"
      trip_proxy.return_trip_date = last_trip_part.scheduled_date.strftime(TRIP_DATE_FORMAT_STRING)
      trip_proxy.return_trip_time = last_trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
      trip_proxy.return_arrive_depart = last_trip_part.is_depart
    end

    # Set the from place
    tp = trip.trip_places.first
    trip_proxy.from_place = tp.name
    trip_proxy.from_raw_address = tp.address
    trip_proxy.from_lat = tp.location.first
    trip_proxy.from_lon = tp.location.last

    if tp.poi
      trip_proxy.from_place_selected_type = POI_TYPE
      trip_proxy.from_place_selected = tp.poi.id
      trip_proxy.from_place_object = tp.poi.to_json(methods: :type_name)
    elsif tp.place
      trip_proxy.from_place_selected_type = PLACES_TYPE
      trip_proxy.from_place_selected = tp.place.id
      trip_proxy.from_place_object = tp.place.to_json(methods: :type_name)
    else
      trip_proxy.from_place_selected_type = CACHED_ADDRESS_TYPE
      trip_proxy.from_place_selected = tp.id
      trip_proxy.from_place_object = tp.to_json(methods: :type_name)
    end
    Rails.logger.info trip_proxy.from_place_object

    # Set the to place
    tp = trip.trip_places.last
    trip_proxy.to_place = tp.name
    trip_proxy.to_raw_address = tp.address
    trip_proxy.to_lat = tp.location.first
    trip_proxy.to_lon = tp.location.last

    if tp.poi
      trip_proxy.to_place_selected_type = POI_TYPE
      trip_proxy.to_place_selected = tp.poi.id
      trip_proxy.to_place_object = tp.poi.to_json(methods: :type_name)
    elsif tp.place
      trip_proxy.to_place_selected_type = PLACES_TYPE
      trip_proxy.to_place_selected = tp.place.id
      trip_proxy.to_place_object = tp.place.to_json(methods: :type_name)
    else
      trip_proxy.to_place_selected_type = CACHED_ADDRESS_TYPE
      trip_proxy.to_place_selected = tp.id
      trip_proxy.to_place_object = tp.to_json(methods: :type_name)
    end
    Rails.logger.info trip_proxy.to_place_object

    return trip_proxy

  end

end
