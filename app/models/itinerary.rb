class Itinerary < ActiveRecord::Base
  include CsHelpers

  # Callbacks
  after_initialize :set_defaults

  # Associations
  belongs_to :trip_part
  belongs_to :mode
  belongs_to :service

  # You should usually *always* used the valid scope
  scope :valid, -> {where('mode_id is not null and server_status=200')}
  scope :selected, -> {where('selected=true')}
  scope :invalid, -> {where('mode_id is null or server_status!=200')}
  scope :visible, -> {where('hidden=false')}
  scope :hidden, -> {where('hidden=true')}
  scope :good_score, -> {where('match_score < 3')}

  # attr_accessible :duration, :cost, :end_time, :legs, :server_message, :mode, :start_time, :server_status, 
  # :service, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary, :hidden,
  # :ride_count, :external_info, :match_score, :missing_information, :missing_information_text, :date_mismatch,
  # :time_mismatch, :too_late, :accommodation_mismatch, :missing_accommodations

  # returns true if this itinerary failed to work
  def failed
    mode.nil?
  end

  def is_return_trip?
    trip_part.is_return_trip?
  end

  def is_return_trip
    trip_part.is_return_trip?
  end

  # returns true if this itinerary can be mapped
  def is_mappable
    return mode.code == 'mode_transit' ? true : false
  end

  # returns true if this itinerary is a walk-only trip. These are a special case of Transit
  # trips that only include a WALK leg
  def is_walk
    legs = get_legs
    return legs.size == 1 && legs.first.mode == Leg::TripLeg::WALK
  end

  # Determines whether we are using rail, bus and rail, or just bus for the transit trips
  def transit_type
    unless mode.code == 'mode_transit'
      return nil
    end
    bus = false
    rail = false
    legs = get_legs
    legs.each do |leg|
      case leg.mode.downcase
        when 'walk'
          next
        when 'bus'
          bus = true
          next
        when 'subway'
          rail = true
          next
        when 'tram'
          rail = true
          next
        when 'rail'
          rail = true
          next
        when 'car'
          return 'drivetransit'
        else
          return 'transit'
      end
    end

    if bus and !rail
      return 'bus'
    elsif !bus and rail
      return 'rail'
    elsif bus and rail
      return 'railbus'
    else
      return 'transit'
    end

  end
  
  # parses the legs and returns an array of TripLeg. If there are no legs then an
  # empty array is returned
  def get_legs
    return legs.nil? ? [] : ItineraryParser.parse(YAML.load(legs))
  end

  def mode_and_routes
    routes = get_legs.map(&:route)
    [mode.name] + routes
  end
  
  def unhide
    self.hidden = false
    self.save()
  end

  def hide
    self.hidden = true
    self.save()
  end

  def hide_others
    trip_part.itineraries.valid.each do |i|
      next if i==self
      i.hidden = true
      i.save
    end
  end

  def notes_count
    [(missing_information ? 1 : 0), 
    (accommodation_mismatch ? 1 : 0),
    ((date_mismatch or time_mismatch or too_late) ? 1 : 0)].sum
  end

  def service_name
    service.name rescue nil
  end

  protected

  # Set resonable defaults for a new itinerary
  def set_defaults
    self.hidden ||= false
  end


end
