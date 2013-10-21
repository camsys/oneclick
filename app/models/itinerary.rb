class Itinerary < ActiveRecord::Base

  # Callbacks
  after_initialize :set_defaults

  # Associations
  belongs_to :planned_trip
  belongs_to :mode
  belongs_to :service

  attr_accessible :duration, :cost, :end_time, :legs, :server_message, :mode, :start_time, :server_status, 
    :service, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary, :hidden,
    :ride_count, :external_info
  
  def self.failed_trip_ids
    select('DISTINCT trip_id').where('status <> 200').order('trip_id')
  end
  
  # returns true if this itinerary is a walk-only trip. These are a special case of Transit
  # trips that only include a WALK leg
  def is_walk
    legs = get_legs
    return legs.size == 1 && legs.first.mode == TripLeg::WALK
  end
  
  # parses the legs and returns an array of TripLeg. If there are no legs then an
  # empty array is returned
  def get_legs
    return legs.nil? ? [] : ItineraryParser.parse(YAML.load(legs))
  end
  
  def unhide
    self.hidden = false
    self.save()
  end

  def hide
    self.hidden = true
    self.save()
  end

protected

  # Set resonable defaults for a new itinerary
  def set_defaults
    self.hidden ||= false
  end    

end
