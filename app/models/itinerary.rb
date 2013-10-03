class Itinerary < ActiveRecord::Base

  # Callbacks
  after_initialize :set_defaults

  # Associations
  belongs_to :planned_trip
  belongs_to :mode
  belongs_to :service

  attr_accessible :duration, :cost, :end_time, :legs, :server_message, :mode, :start_time, :server_status, :service, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary, :hidden
  
  def self.failed_trip_ids
    select('DISTINCT trip_id').where('status <> 200').order('trip_id')
  end
  
  # parses the legs and returns an array of TripLeg
  def get_legs
    return ItineraryParser.parse(YAML.load(legs)) unless legs.nil?
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
