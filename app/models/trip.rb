class Trip < ActiveRecord::Base
    
  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :trip_purpose
  has_many :trip_places, :order => "trip_places.sequence ASC"
  has_many :trip_parts, :order => "trip_parts.sequence ASC"
  
  has_many :valid_itineraries,  :through => :trip_parts, :conditions => 'server_status=200 AND hidden=false', :class_name => 'Itinerary' 
  has_many :hidden_itineraries, :through => :trip_parts, :conditions => 'server_status=200 AND hidden=true', :class_name => 'Itinerary'  
  has_many :itineraries,        :through => :trip_parts, :class_name => 'Itinerary' 
  
  # Scopes
  # Returns a set of trips that have been created between a start and end day
  scope :created_between, lambda {|from_day, to_day| where("trips.created_at > ? AND trips.created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
    
  # Returns a set of trips that are scheduled between the start and end time
  def self.scheduled_between(start_time, end_time)
    # cant do a sorted join here as PG grumbles so doing an in-memory sort on the trips that are returned. The reverse is because we want to order
    # from newest to oldest
    start_time_only = start_time.strftime("%H:%M")
    end_time_only   = end_time.strftime("%H:%M")

    joins(:trip_parts).where("is_return_trip = ? AND trip_parts.scheduled_date >= ? AND trip_parts.scheduled_date <= ? AND trip_parts.scheduled_time >= ? AND trip_parts.scheduled_time <= ?", 
      false, start_time.to_date, end_time.to_date, start_time_only, end_time_only).uniq.sort_by {|x| x.trip_datetime }.reverse
  end
  
  # Returns an array of Trips that have at least one valid itinerary but all
  # of them have been hidden by the user
  def self.rejected
    joins(:itineraries).where('server_status=200 AND hidden=true').uniq
  end
  
  # Returns an array of PlannedTrip where no valid options were generated
  def self.failed
    joins(:itineraries).where('server_status <> 200').uniq
  end
  
  # Returns the date time for the outbound leg of the trip. This is synonymous with the 
  # time and date that the trip is planned for
  def trip_datetime
    trip_parts.first.trip_time
  end
  
  # returns true if the trip is scheduled in advance of the current or passed in date and time.
  def in_the_future(now=Time.now)
    trip_part = trip_parts.first
    if trip_part.nil?
      return false
    end
    
    # First check the days to see of they are equal
    if trip_part.scheduled_date == now.to_date
      # Check just the times, independent of the time zone
      t1 = trip_part.scheduled_time.strftime("%H:%M")
      t2 = now.strftime("%H:%M")
      return t1 > t2 ? true : false
    else
      # Ok, days are not equal so return tru is the trip is in the future
      return trip_part.scheduled_date > now.to_date 
    end
  end
  
  def create_itineraries
    trip_parts.each do |trip_part|
      trip_part.create_itineraries
    end
  end
  
  # Returns a numeric rating score for the trip
  def rating
    if in_the_future
      return nil
    else
      #TODO replace this with actual rating
      return rand(1..5)
    end
  end
  
  # removes all trip places and trip parts from the object  
  def clean
    trip_parts.each do |part| 
      part.itineraries.each { |x| x.destroy }
    end
    trip_parts.each { |x| x.destroy }
    trip_places.each { |x| x.destroy}
    save
  end
  
  # returns true is this trip can be edited or deleted. Note that this
  # bascially comes down to wether the planned trip is in the future or not.
  def can_modify
    if trip_parts.empty?
      return true
    else
      return in_the_future
    end
  end
  
  def to_s
    if trip_places.count > 0
      msg = "From %s to %s" % [trip_places.first, trip_places.last]
      if is_return_trip
        msg << " and back."
      end 
    else
      msg = "Uninitialized" 
    end
    return msg
  end
  
  def is_return_trip
    trip_parts.last.is_return_trip
  end
  
  def from_place
    trip_places.first
  end
  
  def to_place
    trip_places.last
  end

  def cache_trip_places_georaw
    trip_places.each {|tp| tp.cache_georaw}
  end

  def restore_trip_places_georaw
    trip_places.each {|tp| tp.restore_georaw}
  end

end
