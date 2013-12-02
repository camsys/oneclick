class TripPart < ActiveRecord::Base
  
  #associations
  belongs_to :trip
  belongs_to :from_trip_place,  :class_name => "TripPlace", :foreign_key => "from_trip_place_id"
  belongs_to :to_trip_place,    :class_name => "TripPlace", :foreign_key => "to_trip_place_id"

  has_many :itineraries
  # has_many :valid_itineraries, :conditions => 'server_status=200 AND hidden=false', :class_name => 'Itinerary' 
  # has_many :hidden_itineraries, :conditions => 'server_status=200 AND hidden=true', :class_name => 'Itinerary'

  # Ordering of trip parts within a trip. 0 based
  attr_accessible :sequence
  # date and time that the trip part is scheduled for stored as a string
  attr_accessible :scheduled_date, :scheduled_time
  
  
  # true if the trip_time refers to the deaperture time at the origin. False
  # if it is arrival at the destination
  attr_accessible :is_depart
  # true if the trip part is the return trip
  attr_accessible :is_return_trip
 
  # Scopes
  scope :created_between, lambda {|from_time, to_time| where("trip_parts.created_at > ? AND trip_parts.created_at < ?", from_time, to_time).order("trip_parts.trip_time DESC") }
  #scope :scheduled_between, lambda {|from_time, to_time| where("trip_parts.trip_time > ? AND trip_parts.trip_time < ?", from_time, to_time).order("trip_parts.trip_time DESC") }

  def has_hidden_options?
    itineraries.valid.hidden.count > 0
  end

  # We define that an itinerary has been selected if there is exactly 1 visible valid one.
  # We might want a more explicit selection flag in the future.
  def selected?
    itineraries.valid.visible.count == 1
  end
 
  # Converts the trip date and time into a date time object
  def trip_time
    DateTime.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, scheduled_time.hour, scheduled_time.min)
  end
  
  # Returns an array of TripPart that have at least one valid itinerary but all
  # of them have been hidden by the user
  def self.rejected
    joins(:itineraries).where('server_status=200 AND hidden=true')
  end
  
  # Returns an array of TripPart where no valid options were generated
  def self.failed
    joins(:itineraries).where('server_status <> 200')
  end
    
  # returns true if the trip part is scheduled in advance of
  # the current or passed in date
  def in_the_future(now=Time.now)
    trip_time > now
  end
  
  # Generates itineraries for this trip part. Any existing itineraries should have been removed
  # before this method is called.
  def create_itineraries
    create_fixed_route_itineraries
    create_taxi_itineraries
    create_paratransit_itineraries
    create_rideshare_itineraries
  end

  # TODO refactor following 4 methods
  def create_fixed_route_itineraries
    tp = TripPlanner.new
    arrive_by = !is_depart
    result, response = tp.get_fixed_itineraries([from_trip_place.location.first, from_trip_place.location.last],[to_trip_place.location.first, to_trip_place.location.last], trip_time, arrive_by.to_s)
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
    result, response = tp.get_taxi_itineraries([from_trip_place.location.first, from_trip_place.location.last],[to_trip_place.location.first, to_trip_place.location.last], trip_time)
    if result
      itinerary = tp.convert_taxi_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('server_status'=>500, 'server_message'=>response)
    end
  end

  def create_paratransit_itineraries
    eh = EligibilityHelpers.new
    fh = FareHelper.new
    itineraries = eh.get_accommodating_and_eligible_services_for_traveler(self)
    itineraries = eh.get_eligible_services_for_trip(self, itineraries)
    itineraries.each do |itinerary|
      new_itinerary = Itinerary.new(itinerary)
      fh.calculate_fare(new_itinerary)
      self.itineraries << new_itinerary
    end
  end

 def create_rideshare_itineraries
    tp = TripPlanner.new
    trip.restore_trip_places_georaw
    Rails.logger.info "create_rideshare_itineraries"
    Rails.logger.info trip.trip_places.collect {|trp| trp.raw}
    result, response = tp.get_rideshare_itineraries(from_trip_place, to_trip_place, trip_time)
    if result
      itinerary = tp.convert_rideshare_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('server_status'=>500, 'server_message'=>response)
    end
  end  

end
