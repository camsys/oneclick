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
  scope :booked, -> {where.not(booking_confirmation: nil)}
  scope :created_between, lambda {|from_day, to_day| where("itineraries.created_at > ? AND itineraries.created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
  # NOTE that: mode scopes are based on :returned_mode_code as it represents the real mode code
  #    when itinerary.mode.code == :mode_transit, itinerary.returned_mode_code could be
  #        mode_transit
  #        mode_walk (is_walk == true)
  #        mode_car (is_car == true)
  #        mode_bicycle (is_bicycle == true)
  scope :with_mode, ->(mode) {where(returned_mode_code: mode)}
  scope :without_mode, ->(mode) {where.not(returned_mode_code: mode)}

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

    return mode.code.in? ['mode_transit', 'mode_bicycle', 'mode_car', 'mode_walk', 'mode_paratransit', 'mode_taxi', 'mode_rideshare']
  end

  # returns true if this itinerary is a walk-only trip. These are a special case of Transit
  # trips that only include a WALK leg
  def is_walk
    return true if self.returned_mode_code == "mode_walk"

    return Itinerary.is_walk? get_legs(false)
  end

  def self.is_walk?(legs)
    legs ||= []
    return legs.size == 1 && legs.first.mode == Leg::TripLeg::WALK
  end

  # return true if this itinerary is a car-only trip. These are a special case of transit
  # trips that only include a CAR leg
  def is_car
    return true if self.returned_mode_code == "mode_car"

    return Itinerary.is_car? get_legs(false)
  end

  def self.is_car?(legs)
    legs ||= []
    return legs.size == 1 && legs.first.mode == Leg::TripLeg::CAR
  end

  # returns true if this itinerary is contains only bicycle and walking legs. These are a special case of Transit
  # trips that only include a BICYCLE leg
  def is_bicycle
    return true if self.returned_mode_code == "mode_bicycle"

    return Itinerary.is_bicycle? get_legs(false)
  end

  def self.is_bicycle?(legs)
    legs ||= []
    
    modes = legs.collect{ |m| m.mode }.uniq
    unless Leg::TripLeg::BICYCLE.in? modes
      return false
    end

    if modes.count == 1
      return true
    elsif modes.count > 2
      return false
    else
      return Leg::TripLeg::WALK.in? legs
    end
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
        when *Leg::TransitLeg::RAIL_LEGS
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
    ((date_mismatch or time_mismatch or too_late or too_early) ? 1 : 0)].sum
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

  #OTP is setting drive time and bicycle time as walk time.  This is a temporary work-around
  def clear_walk_time
    if self.is_car
      self.walk_time = 0
      self.walk_distance = 0
    end

    if self.is_bicycle
      walk_time = 0
      walk_distance = 0
      get_legs(false).each do |leg|
        if leg.mode == Leg::TripLeg::WALK
          walk_time += leg.duration
          walk_distance += leg.distance
        end
      end
      self.walk_distance = walk_distance
      self.walk_time = walk_time
    end
  end

  # Set resonable defaults for a new itinerary
  def set_defaults
    self.hidden ||= false
    @legs = []
  end


end
