class Trip < ActiveRecord::Base
  include Rateable # mixin to handle all rating methods
  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :trip_purpose
  belongs_to :multi_origin_dest_trip
  belongs_to :agency
  belongs_to :outbound_provider, class_name: "Provider", foreign_key: "outbound_provider_id"
  belongs_to :return_provider, class_name: "Provider", foreign_key: "return_provider_id"
  has_many :trip_places, -> {order("trip_places.sequence ASC")}
  has_many :trip_parts, -> {order("trip_parts.sequence ASC")}
  has_many :itineraries, :through => :trip_parts, :class_name => 'Itinerary'
  has_and_belongs_to_many :desired_modes, class_name: 'Mode', join_table: :trips_desired_modes, association_foreign_key: :desired_mode_id
  has_one :satisfaction_survey

  # Scopes
  scope :created_between, lambda {|from_day, to_day| where("trips.created_at >= ? AND trips.created_at <= ?", from_day.at_beginning_of_day, to_day.at_end_of_day) }
  scope :with_role, lambda {|role_name| 
    includes(user: :roles)
    .where(roles: {name: role_name})
    .references(user: :roles)
  }
  scope :without_role, lambda {|role_name| 
    includes(user: :roles)
    .where.not(roles: {name: role_name})
    .references(user: :roles)
  }
  
  scope :with_ui_mode, -> (ui_mode) {where(ui_mode: ui_mode)}
  scope :by_provider, ->(p) { joins(itineraries: {service: :provider}).where('providers.id=?', p).distinct }
  # .join(:services).join(:providers) }
  # .where('providers.id=?', p)}
  scope :by_agency, ->(a) { joins(user: :approved_agencies).where('agencies.id' => a) }
  scope :feedbackable, -> { includes(:itineraries).where(itineraries: {selected: true}, trips: {needs_feedback_prompt: true}).uniq}
  scope :scheduled_before, lambda {|to_day| where("trips.scheduled_time < ?", to_day) }

  def self.planned_between(start_time = nil, end_time = nil)
    base_trips = Trip.where(is_planned: true)

    start_time = start_time.at_beginning_of_day if start_time
    end_time = end_time.at_end_of_day if end_time

    base_trips = base_trips.where("trips.created_at >= ?", start_time) if start_time
    base_trips = base_trips.where("trips.created_at <= ?", end_time) if end_time

    base_trips
   
  end

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
    trip.agency = user.agency
    trip.user = traveler
    trip.trip_purpose = TripPurpose.find(trip_proxy.trip_purpose_id)
    trip.desired_modes = Mode.where(code: trip_proxy.modes)

    if traveler.has_vehicle? and trip.desired_modes.include?(Mode.transit)
      trip.desired_modes << Mode.park_transit
    end

    from_place = TripPlace.new.from_trip_proxy_place(trip_proxy.from_place_object, 0,
      trip_proxy.from_place, trip_proxy.map_center, traveler)
    
    to_place = TripPlace.new.from_trip_proxy_place(trip_proxy.to_place_object, 1,
      trip_proxy.to_place, trip_proxy.map_center, traveler)
    # bubble up any errors finding places
    trip.errors.add(:from_place, from_place.errors[:base].first) unless from_place.errors[:base].empty?
    trip.errors.add(:to_place, to_place.errors[:base].first) unless to_place.errors[:base].empty?

    trip.trip_places << from_place
    trip.trip_places << to_place

    trip.user_agent = trip_proxy.user_agent
    trip.ui_mode = trip_proxy.ui_mode
    trip.kiosk_code = trip_proxy.kiosk_code

    # set the sequence counter for when we have multiple trip parts
    sequence = 0

    unless trip_proxy.user_agent.nil?
      if trip_proxy.user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
        trip_date = Date.strptime(trip_proxy.outbound_trip_date, '%Y-%m-%d')
      else
        trip_date = Date.strptime(trip_proxy.outbound_trip_date, '%m/%d/%Y')
      end
    else
      trip_date = Date.strptime(trip_proxy.outbound_trip_date, '%m/%d/%Y')
    end

    # Create the outbound trip part
    trip_part = TripPart.new
    trip_part.trip = trip
    trip_part.sequence = sequence
    # TODO Change this when we change view to return non-localied value.
    trip_part.is_depart = trip_proxy.outbound_arrive_depart
    trip_part.scheduled_date = trip_date
    trip_part.scheduled_time = Time.zone.parse(trip_date.year.to_s + '-' + trip_date.month.to_s + '-' + trip_date.day.to_s + ' ' + trip_proxy.outbound_trip_time).in_time_zone("UTC")
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
      trip_part.is_depart = trip_proxy.return_arrive_depart
      trip_part.is_return_trip = true
      unless trip_proxy.user_agent.nil?
        if trip_proxy.user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
          return_trip_date = Date.strptime(trip_proxy.return_trip_date, '%Y-%m-%d')
        else
          return_trip_date = Date.strptime(trip_proxy.return_trip_date, '%m/%d/%Y')
        end
      else
        return_trip_date = Date.strptime(trip_proxy.return_trip_date, '%m/%d/%Y')
      end
      trip_part.scheduled_date = return_trip_date
      trip_part.scheduled_time = Time.zone.parse(return_trip_date.year.to_s + '-' + return_trip_date.month.to_s + '-' + return_trip_date.day.to_s + ' ' + trip_proxy.return_trip_time).in_time_zone("UTC")
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

  def create_itineraries
    if ENV['MULTITHREAD']
      create_itineraries_mt
    else
      create_itineraries_st
    end

  end

  # Shortcut that creates itineraries for all trip parts
  # This function simply delegates to the trip parts to generate
  # their own itineraries
  def create_itineraries_st
    Rails.logger.info "Creating itineraries single-threaded"
    trip_parts.each do |trip_part|
      trip_part.create_itineraries
    end



  end

  def create_itineraries_mt
    Rails.logger.info "Creating itineraries multithreaded"
    threads = []
    trip_parts.each do |trip_part|
      threads << Thread.new do
        begin
          Rails.logger.info "#{Time.now} #{Thread.current} Starting trip part"
          trip_part.create_itineraries
          Rails.logger.info "#{Time.now} #{Thread.current} Back from trip part"
        ensure
          begin
            if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
              Rails.logger.info "In ensure, closing connection"
              ActiveRecord::Base.connection.close
            end
          rescue Exception => e
            Rails.logger.error e
            raise e
          end
        end
      end
    end
    threads.each do |t|
      Rails.logger.info "#{Time.now} Waiting on Thread #{t}"
      t.join
      Rails.logger.info "#{Time.now} Done on Thread #{t}"
    end
  end

  # removes all trip places and trip parts from the object
  def clean
    remove_itineraries
    trip_parts.each { |x| x.destroy }
    trip_places.each { |x| x.destroy}
    save
  end

  def remove_itineraries
    trip_parts.each do |part|
      part.itineraries.each { |x| x.destroy }
    end
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

  def cant_modify_reason
    in_the_future ? "(can modify)" : "Can't modify this trip: either the depart or arrive time is in the past."
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
  #This Logic breaks with 1-way trips. trips_parts.last = trip_parts.first.
  #It is causing issues with the booking confirmations.
  def return_part
    trip_parts.last
  end

  def get_return_part
    if trip_parts.count > 1
      trip_parts.last
    else
      nil
    end
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

  # Returns an array of selected itineraries on a trip.  Empty array if none selected
  def selected_itineraries
    itineraries.where(selected: true)
  end

  def selected_services
    # Hack.  Returns an array of AR objects, not an AR association
    selected_itineraries.map(&:service).uniq.compact
  end

  def planned_by_agent
    creator != user && creator.agency # NB: This will also apply to users that are buddies and happen to work for agencies
  end

  def md5_hash
    Digest::MD5.hexdigest(self.id.to_s + self.user.id.to_s + self.created_at.to_s)
  end

  def eligibility_dependent?
    desired_modes.where(elig_dependent: true).count > 0
  end

  def is_booked?
    trip_parts.each do |trip_part|
      if trip_part.is_booked?
        return true
      end
    end
    false
  end

  def next_part trip_part
    return nil if trip_parts.count==1
    i = trip_parts.find_index {|tp| tp==trip_part}
    raise "Trip part is not part of this trip" if i.nil?
    i += 1
    return nil if i==trip_parts.count
    trip_parts[i]
  end

  def prev_part trip_part
    return nil if trip_parts.count==1
    i = trip_parts.find_index {|tp| tp==trip_part}
    raise "Trip part is not part of this trip" if i.nil?
    i -= 1
    return nil if i<0
    trip_parts[i]
  end

  #Unselect all selected itineraries
  def unselect_all
    self.itineraries.selected.each do |i|
      i.update_attribute :selected, false
    end
  end

  def status
    #Statuses
    # Started, Planned, Booked
    return {code: 'BOOKED', description: "Trips booked."} if self.is_booked?
    return {code: 'PLANNED', description: "Trip planned but not booked."} if self.both_parts_selected?
    return {code: 'STARTED', description: "Trip started but not planned."}

  end

  private

  def validate_at_least_one_trip_place
    errors.add(:trip_places, 'is empty') unless trip_places.count > 0
  end

  def validate_at_least_one_trip_part
    errors.add(:trip_parts, 'is empty') unless trip_parts.count > 0
  end

end
