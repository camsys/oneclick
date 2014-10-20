require 'carrierwave/orm/activerecord'

class Itinerary < ActiveRecord::Base
  include CsHelpers

  mount_uploader :map_image, BaseUploader

  # Callbacks
  after_initialize :set_defaults
  before_save :clear_walk_time

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
    legs = get_legs(false)
    return legs.size == 1 && legs.first.mode == Leg::TripLeg::WALK
  end

  # return true if this itinerary is a car-only trip. These are a special case of transit
  # trips that only include a CAR leg
  def is_car
    legs = get_legs(false)
    return legs.size ==1 && legs.first.mode == Leg::TripLeg::CAR
  end

  # returns true if this itinerary is a bicycle-only trip. These are a special case of Transit
  # trips that only include a BICYCLE leg
  def is_bicycle
    legs = get_legs(false)
    return legs.size == 1 && legs.first.mode == Leg::TripLeg::BICYCLE
  end

  # Determines whether we are using rail, bus and rail, or just bus for the transit trips
  def transit_type
    unless mode.code == 'mode_transit'
      return nil
    end
    bus = false
    rail = false
    legs = get_legs(false)
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
  def get_legs(include_geometry = true)
    if @legs.empty?
      @legs = legs.nil? ? [] : ItineraryParser.parse(YAML.load(legs), include_geometry)
    end
    @legs
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
    Rails.logger.info "hide_others"
    trip_part.itineraries.valid.each do |i|
      Rails.logger.info i.ai
      next if i==self
      Rails.logger.info "HIDING"
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

  def estimate_duration base_duration, minimum_duration, duration_factor, trip_time, is_depart
    self.duration_estimated = true
    if base_duration.nil?
      duration = minimum_duration
    else
      duration =
        [base_duration * duration_factor,
         minimum_duration].max
    end
    Rails.logger.info "Factored duration: #{duration} minutes"
    if is_depart
      self.start_time = trip_time
      self.end_time = start_time + duration
    else
      self.end_time = trip_time
      self.start_time = end_time - duration
    end
    Rails.logger.info "AFTER"
    Rails.logger.info duration.ai
    Rails.logger.info start_time.ai
    Rails.logger.info end_time.ai
  end

  protected

  #OTP is setting drive time as walk time.  This is a temporary work-around
  def clear_walk_time
    if self.is_car
      self.walk_time = 0
    end
  end

  # Set resonable defaults for a new itinerary
  def set_defaults
    self.hidden ||= false
    @legs = []
  end


end
