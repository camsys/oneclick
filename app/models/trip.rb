class Trip < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :trip_purpose
  has_many :trip_places, -> {order("trip_places.sequence ASC")}
  has_many :trip_parts, -> {order("trip_parts.sequence ASC")}

  #Accessible attributes
  # attr_accessible :user_comments, :taken, :rating, :trip_purpose
  
  has_many :itineraries,        :through => :trip_parts, :class_name => 'Itinerary' 

  # We don't actually run these validations; sort of complicated to make it work
  # and I don't want to deal with it right now.
  # validate :validate_at_least_one_trip_place
  # validate :validate_at_least_one_trip_part

  # Scopes
  # Returns a set of trips that have been created between a start and end day
  scope :created_between, lambda {|from_day, to_day| where("trips.created_at > ? AND trips.created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
  # scope :by_provider, ->(p) { where("distinct t.* from trips t join trip_parts tp on tp.trip_id=t.id " +
  #   "join itineraries i on i.trip_part_id=tp.id " +
  #   "join services s on s.id=i.service_id " +
  #   "join providers p on p.id=s.provider_id") }
  scope :by_provider, ->(p) { joins(itineraries: {service: :provider}).where('providers.id=?', p).distinct }
  # .join(:services).join(:providers) }
    # .where('providers.id=?', p)}

  scope :by_agency, ->(a) { joins(user: :approved_agencies).where('agencies.id' => a) }

  # Returns a set of trips that are scheduled between the start and end time
  def self.scheduled_between(start_time, end_time)
    
    # cant do a sorted join here as PG grumbles so doing an in-memory sort on the trips that are returned after we have performed a sub-filter on them. The reverse 
    #is because we want to order from newest to oldest
    res = joins(:trip_parts).where("sequence = ? AND trip_parts.scheduled_date >= ? AND trip_parts.scheduled_date <= ?", 0, start_time.to_date, end_time.to_date).uniq
    # Now we need to filter through the results and remove any which fall outside the time range
    res = res.reject{|x| ! x.scheduled_in_range(start_time, end_time) }
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

  def self.create_from_proxy trip_proxy, user, traveler
    trip = Trip.new()
    trip.creator = user
    trip.user = traveler
    trip.trip_purpose = TripPurpose.find(trip_proxy.trip_purpose_id)

    from_place = TripPlace.new.from_trip_proxy_place(trip_proxy.from_place_object, 0,
      trip_proxy.from_place, trip_proxy.map_center)
    to_place = TripPlace.new.from_trip_proxy_place(trip_proxy.to_place_object, 1,
      trip_proxy.to_place, trip_proxy.map_center)

    trip.trip_places << from_place
    trip.trip_places << to_place

    # set the sequence counter for when we have multiple trip parts
    sequence = 0

    trip_date = Date.strptime(trip_proxy.trip_date, '%m/%d/%Y')

    # Create the outbound trip part
    trip_part = TripPart.new
    trip_part.trip = trip
    trip_part.sequence = sequence
    # TODO Change this when we change view to return non-localied value.
    trip_part.is_depart = trip_proxy.arrive_depart == 'Departing At' ? true : false
    trip_part.scheduled_date = trip_date
    trip_part.scheduled_time = Time.zone.parse(trip_date.year.to_s + '-' + trip_date.month.to_s + '-' + trip_date.day.to_s + ' ' + trip_proxy.trip_time).in_time_zone("UTC")
    trip_part.from_trip_place = from_place
    trip_part.to_trip_place = to_place

    raise 'TripPart not valid' unless trip_part.valid?
    trip.trip_parts << trip_part

    trip.scheduled_date = trip_part.scheduled_date
    trip.scheduled_time = trip_part.scheduled_time

    # create the round trip if needed
    if trip_proxy.is_round_trip == "1"
      sequence += 1
      trip_part = TripPart.new
      trip_part.trip = trip
      trip_part.sequence = sequence
      trip_part.is_depart = true
      trip_part.is_return_trip = true
      trip_part.scheduled_date = trip_date
      trip_part.scheduled_time = Time.zone.parse(trip_date.year.to_s + '-' + trip_date.month.to_s + '-' + trip_date.day.to_s + ' ' + trip_proxy.return_trip_time).in_time_zone("UTC")
      trip_part.from_trip_place = to_place
      trip_part.to_trip_place = from_place

      raise 'TripPart not valid' unless trip_part.valid?
      trip.trip_parts << trip_part
    end
    trip
  end

  # Returns true if the trip is scheduled to start withing the period
  # start_time..end_time. This method ignores timezones as all trip times are relative
  # to the user
  def scheduled_in_range(start_time, end_time)

    # See if the trip date is on or after the start time
    start_time_res = in_the_future(start_time)
    # See if the trip date is on or after the end time
    end_time_res = in_the_future(end_time)
    
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
  def in_the_future(compare_time=DateTime.current.utc)
    trip_part = trip_parts.first
    if trip_part.nil?
      return false
    end
    
    return trip_part.scheduled_time > compare_time ? true : false

    # First check the days to see of they are equal
    if trip_part.scheduled_date == compare_time.to_date
      # Check just the times, independent of the time zone
      t1 = trip_part.scheduled_time.strftime("%H:%M")
      t2 = compare_time.strftime("%H:%M")
      return t1 > t2 ? true : false
    else
      # Ok, days are not equal so return true if the trip is in the future
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

  private

  def validate_at_least_one_trip_place
    errors.add(:trip_places, 'is empty') unless trip_places.count > 0
  end

  def validate_at_least_one_trip_part
    errors.add(:trip_parts, 'is empty') unless trip_parts.count > 0
  end

end
