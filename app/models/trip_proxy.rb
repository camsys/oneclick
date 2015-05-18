class TripProxy < Proxy
  # User object for the traveler
  attr_accessor :traveler
  # Type of operation. Defined in TripSupport. One of MODE_NEW, MODE_EDIT, MODE_REPEAT
  attr_accessor :mode
  # Id of the trip being re-planned, edited, etc. Null if mode is NEW
  attr_accessor :id, :map_center
  attr_accessor :trip_options
  attr_accessor :trip_token, :agency_token
  attr_accessor :kiosk_code

  attr_accessor :user_agent, :ui_mode

  attr_accessor :outbound_trip_date, :outbound_arrive_depart, :outbound_trip_time
  attr_accessor :is_round_trip, :return_trip_time, :return_arrive_depart, :return_trip_date

  validate :return_trip_date, :presence => true
  validate :return_trip_time, :presence => true
  validates :outbound_trip_date, :presence => true
  validates :outbound_trip_time, :presence => true

  validate :datetime_cannot_be_before_now

  include TripsSupport
  include Trip::From
  include Trip::PickupTime
  include Trip::Purpose
  include Trip::ReturnTime
  include Trip::To
  include Trip::Modes

  def initialize(attrs = {})
    Rails.logger.info "\n===> Initializing trip_proxy\n"
    super
    attrs.each do |k, v|
      Rails.logger.info "SETTING #{k}=#{v}"
      if self.respond_to? k
        self.send "#{k}=", v
      end
    end
    @return_trip_date ||= @outbound_trip_date
    @modes ||= Mode.all.collect{|m| m.code}
    @modes_desired = @modes
    # Modify modes to reflect transit
    # Using array select with side effects
    if (@modes)
      # if bus or rail are not visible, then ignore invisible modes for
      # determining whether or not transit mode is added
      transit = bus = rail = bike = drive = nil
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
          transit = mode
          false
        when Mode.bicycle.code
          bike = mode
          true
        when Mode.car.code
          drive = mode
          true
        else
          true
        end
      end
    end

    if (bus && rail) || (bus && !Mode.rail.visible) || (rail && !Mode.bus.visible) ||
        (transit && !Mode.rail.visible && !Mode.bus.visible)
      @modes << Mode.transit.code
      @modes << Mode.bike_park_transit.code if bike
      @modes << Mode.park_transit.code if drive
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
    temp_time = trip_part.scheduled_time

    if mobile?(trip.user_agent)
      trip_proxy.outbound_trip_date = trip_part.scheduled_date.strftime("%Y-%m-%d")
      trip_proxy.outbound_trip_time = trip_part.scheduled_time.in_time_zone.strftime("%H:%M")
    else
      trip_proxy.outbound_trip_date = trip_part.scheduled_date.strftime(TRIP_DATE_FORMAT_STRING)
      trip_proxy.outbound_trip_time = trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    end

    # Check for return trips
    if trip.trip_parts.count > 1
      last_trip_part = trip.trip_parts.last
      trip_proxy.is_round_trip = last_trip_part.is_return_trip ? "1" : "0"

      if mobile?(trip.user_agent)
        trip_proxy.return_trip_date = last_trip_part.scheduled_date.strftime("%Y-%m-%d")
        trip_proxy.return_trip_time = last_trip_part.scheduled_time.in_time_zone.strftime("%H:%M")
      else
        trip_proxy.return_trip_date = last_trip_part.scheduled_date.strftime(TRIP_DATE_FORMAT_STRING)
        trip_proxy.return_trip_time = last_trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
      end

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

    trip_proxy.user_agent = trip.user_agent
    trip_proxy.ui_mode = trip.ui_mode
    trip_proxy.kiosk_code = trip.kiosk_code

    return trip_proxy

  end

  def self.mobile?(user_agent)
    unless user_agent.nil?
      user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
    end
  end

  # Returns the trip date and time as a DateTime class
  def trip_datetime
    begin
      outbound_datetime = Chronic.parse([outbound_trip_date, outbound_trip_time].join(' '))
      return_datetime = Chronic.parse([return_trip_date, return_trip_time].join(' '))
      return [outbound_datetime, return_datetime]
    rescue Exception => e
      Rails.logger.warn "trip_datetime #{outbound_trip_date} #{outbound_trip_time}"
      Rails.logger.warn e.message
      raise e
    end
  end

  protected

  # Validation. Ensure that the user is planning a trip for the future.
  def datetime_cannot_be_before_now
    true if trip_datetime.count(nil) == 2
    if trip_datetime[0] < Date.today
      errors.add(:outbound_trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
      false
    end
    if trip_datetime[0] < Time.current
      errors.add(:outbound_trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
      false
    end
    if is_round_trip == 1
      if trip_datetime[1] < Date.today
        errors.add(:return_trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
        false
      end
      if trip_datetime[1] < Time.current
        errors.add(:return_trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
        false
      end
    end
    true
  end
end
