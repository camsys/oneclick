class Trip < ActiveRecord::Base
    
  attr_accessor :name

  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :trip_purpose
  has_many :trip_places
  has_many :planned_trips, :order => "planned_trips.trip_datetime DESC"
  
  # Scopes
  scope :created_between, lambda {|from_day, to_day| where("created_at > ? AND created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }

  # removes all trip places and planned trips from the object  
  def clean
    planned_trips.each do |pt| 
      pt.itineraries.each { |x| x.destroy }
    end
    planned_trips.each { |x| x.destroy }
    trip_places.each { |x| x.destroy}
    save
  end
  
  # returns true is this trip can be edited or deleted. Note that this
  # bascially comes down to wether the planned trip is in the future or not.
  def can_modify
    if planned_trips.empty?
      return true
    else
      return planned_trips.first.in_the_future
    end
  end
  
  def to_s
    if trip_places.count > 0
      "From %s to %s" % [trip_places.first, trip_places.last]
    else
      "Uninitialized" 
    end  
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

  def origin
    self.trip_places.order('sequence').first
  end

  def destination
    self.trip_places.order('sequence').last
  end


end
