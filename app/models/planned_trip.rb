class PlannedTrip < ActiveRecord::Base
  
  #associations
  belongs_to :trip
  belongs_to :trip_status
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :itineraries
  has_many :valid_itineraries, :conditions => 'server_status=200 AND hidden=false', :class_name => 'Itinerary' 
  has_many :hidden_itineraries, :conditions => 'server_status=200 AND hidden=true', :class_name => 'Itinerary' 
  
  attr_accessible :trip_datetime, :is_depart
 
  def create_itineraries
    create_fixed_route_itineraries
    create_taxi_itineraries
    create_paratransit_itineraries
  end

  # TODO refactor following 3 methods
  def create_fixed_route_itineraries
    tp = TripPlanner.new
    arrive_by = !is_depart
    from_place = trip.trip_places.first
    to_place = trip.trip_places.last
    result, response = tp.get_fixed_itineraries([from_place.location.first, from_place.location.last],[to_place.location.first, to_place.location.last], trip_datetime.in_time_zone, arrive_by.to_s)
    if result
      tp.convert_itineraries(response).each do |itinerary|
        itineraries << Itinerary.new(itinerary)
      end
    else
      itineraries << Itinerary.new('server_status'=>response['id'], 'server_status'=>response['msg'])
    end
  end

  def create_taxi_itineraries
    tp = TripPlanner.new
    from_place = trip.trip_places.last
    to_place = trip.trip_places.last
    result, response = tp.get_taxi_itineraries([from_place.location.first, from_place.location.last],[to_place.location.first, to_place.location.last], trip_datetime.in_time_zone)
    if result
      itinerary = tp.convert_taxi_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('server_status'=>500, 'server_message'=>response)
    end
  end

  def create_paratransit_itineraries
    #TODO: This is just a place holder that currently returns demo data only.
    tp = TripPlanner.new
    from_place = trip.trip_places.last
    to_place = trip.trip_places.last
    result, response = tp.get_paratransit_itineraries([from_place.location.first, from_place.location.last],[to_place.location.first, to_place.location.last], trip_datetime.in_time_zone)
    if result
      itinerary = tp.convert_paratransit_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('server_status'=>500, 'server_status'=>response)
    end
  end
 
end
