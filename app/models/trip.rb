class Trip < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :trip_purpose
  has_many :trip_places, :order => "trip_places.sequence ASC"
  has_many :trip_parts, :order => "trip_parts.sequence ASC"

  #Accessible attributes
  attr_accessible :user_comments, :taken, :rating, :trip_purpose
  
  # has_many :valid_itineraries,  :through => :trip_parts, :conditions => 'server_status=200 AND hidden=false AND match_score < 3', :class_name => 'Itinerary'
  # has_many :hidden_itineraries, :through => :trip_parts, :conditions => 'server_status=200 AND hidden=true AND match_score < 3', :class_name => 'Itinerary'
  has_many :itineraries,        :through => :trip_parts, :class_name => 'Itinerary' 
  
  # Scopes
  # Returns a set of trips that have been created between a start and end day
  scope :created_between, lambda {|from_day, to_day| where("trips.created_at > ? AND trips.created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
    
  # Returns a set of trips that are scheduled between the start and end time
  def self.scheduled_between(start_time, end_time)
    puts "scheduled_between() start_time = #{start_time}, end_time = #{end_time}"
    
    # cant do a sorted join here as PG grumbles so doing an in-memory sort on the trips that are returned after we have performed a sub-filter on them. The reverse 
    #is because we want to order from newest to oldest
    res = joins(:trip_parts).where("sequence = ? AND trip_parts.scheduled_date >= ? AND trip_parts.scheduled_date <= ?", 0, start_time.to_date, end_time.to_date).uniq
    puts "Primary filter has #{res.count} results"
    # Now we need to filter through the results and remove any which fall outside the time range
    res = res.reject{|x| ! x.scheduled_in_range(start_time, end_time) }
    puts "Secondary filter has #{res.count} results"
    return res.sort_by {|x| x.trip_datetime }.reverse

  end
  
  # Returns an array of Trips that have at least one valid itinerary but all
  # of them have been hidden by the user
  def self.rejected
    joins(:itineraries).where('server_status=200 AND hidden=true').uniq
  end
  
  # Returns an array of Trips where no valid options were generated
  def self.failed
    joins(:itineraries).where('server_status <> 200').uniq
  end

  # Returns true if the trip is scheduled to start withing the period
  # start_time..end_time. This method ignores timezones as all trip times are relative
  # to the user
  def scheduled_in_range(start_time, end_time)

    puts "start_time = #{start_time}, end_time = #{end_time}, trip_datetime = #{trip_datetime}"
    
    # See if the trip date is on or after the start time
    start_time_res = in_the_future(start_time)
    # See if the trip date is on or after the end time
    end_time_res = in_the_future(end_time)
    puts "start_time_res = #{start_time_res}, end_time_res = #{end_time_res}"
    
    if start_time_res
      # the trip is on or after the start time
      if end_time_res
        # the trip is after the end time
        return false
      else
        # the trip is after the start time and before the end time
        return true
      end
    else
      # the trip is before the start time
      return false
    end
  end
  
  # Returns the date time for the outbound leg of the trip. This is synonymous with the 
  # time and date that the trip is planned for
  def trip_datetime
    trip_parts.first.trip_time
  end
  
  # returns true if the trip is scheduled in advance of the current or passed in date and time.
  def in_the_future(compare_time=Time.current.utc)
    trip_part = trip_parts.first
    if trip_part.nil?
      return false
    end
    puts "compare_time = #{compare_time}, trip_part.scheduled_date = #{trip_part.scheduled_date}"
    
    # First check the days to see of they are equal
    if trip_part.scheduled_date == compare_time.to_date
      # Check just the times, independent of the time zone
      t1 = trip_part.scheduled_time.strftime("%H:%M")
      t2 = compare_time.strftime("%H:%M")
      puts "t1 = #{t1}, t2 = #{t2}"
      return t1 > t2 ? true : false
    else
      # Ok, days are not equal so return true if the trip is in the future
      puts "trip_part.scheduled_date = #{trip_part.scheduled_date}, compare_time.to_date = #{compare_time.to_date}"
      return trip_part.scheduled_date > compare_time.to_date 
    end
  end
  
  # Shortcut that creates itineraries for all trip parts
  # This function simply delegates to the trip parts to generate
  # their own itineraries
  def create_itineraries
    trip_parts.each do |trip_part|
      trip_part.create_itineraries
    end
  end
  
  # Returns a numeric rating score for the trip
  def get_rating
    if self.rating
      return self.rating
    else
      return 0
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
  
  # Overrides the default to string method.
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
  
  # Returns true if this trip has a return leg, false otherwise
  def is_return_trip
    trip_parts.last.is_return_trip
  end
  
  # Shortcut to identify the place where the trip leaves from
  def from_place
    trip_places.first
  end
  
  # Shortcut to identify the last place the trip visits. If the trip is a round
  # trip this is the last place before heading back to the starting place
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

  def outbound_part
    trip_parts.first
  end

  # TOOD This needs to change when/if we have multi-leg trips
  def return_part
    trip_parts.last
  end

  def both_parts_selected?
    trip_parts.first.selected? and trip_parts.last.selected?
  end

  def any_parts_selected?
    trip_parts.first.selected? or trip_parts.last.selected?
  end

  def only_outbound_selected?
    trip_parts.first.selected? and !trip_parts.last.selected?
  end

  def only_return_selected?
    !trip_parts.first.selected? and trip_parts.last.selected?
  end

  def md5_hash
    Digest::MD5.hexdigest(self.id.to_s + self.user.id.to_s + self.created_at.to_s)
  end

end
