class TripPart < ActiveRecord::Base

  #associations
  belongs_to :trip
  belongs_to :from_trip_place,  :class_name => "TripPlace", :foreign_key => "from_trip_place_id"
  belongs_to :to_trip_place,    :class_name => "TripPlace", :foreign_key => "to_trip_place_id"

  has_many :itineraries

  # Ordering of trip parts within a trip. 0 based
  # attr_accessible :sequence
  # date and time that the trip part is scheduled for stored as a string
  # attr_accessible :scheduled_date, :scheduled_time, :from_trip_place, :to_trip_place


  # true if the trip_time refers to the deaperture time at the origin. False
  # if it is arrival at the destination
  # attr_accessible :is_depart
  # true if the trip part is the return trip
  # attr_accessible :is_return_trip

  validates :from_trip_place, presence: true
  validates :to_trip_place, presence: true

  #For Booking
  attr_accessor :passenger1_type, :passenger1_space_type, :passenger2_type, :passenger2_space_type, :passenger3_type, :passenger3_space_type, :booking_trip_purpose_code, :guests, :attendants, :mobility_devices

  # Scopes
  scope :created_between, lambda {|from_time, to_time| where("trip_parts.created_at > ? AND trip_parts.created_at < ?", from_time, to_time).order("trip_parts.trip_time DESC") }
  #scope :scheduled_between, lambda {|from_time, to_time| where("trip_parts.trip_time > ? AND trip_parts.trip_time < ?", from_time, to_time).order("trip_parts.trip_time DESC") }

  def has_hidden_options?
    itineraries.valid.hidden.count > 0
  end

  def is_return_trip?
    is_return_trip
  end

  def get_return_part
    return self.trip.get_return_part
  end


  ##################################
  ### Booking Specific Methods #####
  ##################################

  def is_bookable?
    unless selected?
      return false
    end
    return selected_itinerary.is_bookable?
  end

  def service_is_bookable?
    unless selected?
      return false
    end

    if self.selected_itinerary.service.nil?
      return false
    end

    return self.selected_itinerary.service.is_bookable?

  end

  def is_booked?
    if self.itineraries.where.not(booking_confirmation: nil).count > 0
      true
    else
      false
    end
  end

  # return true if this trip_part's selected service is associated with it's user
  def is_associated?
    itinerary = self.selected_itinerary
    if itinerary.nil?
      return false
    end

    service = itinerary.service
    if service.nil?
      return false
    end

    return service.is_associated_with_user? self.trip.user

  end

  def get_booking_trip_purposes
    if selected?
      return selected_itinerary.get_booking_trip_purposes
    else
      return {}
    end
  end

  def get_passenger_types
    if selected?
      return selected_itinerary.get_passenger_types
    else
      return {}
    end
  end

  def get_space_types
    if selected?
      return selected_itinerary.get_space_types
    else
      return {}
    end
  end

  def unit
    self.from_trip_place.unit
  end

  ### END Booking Specific Methods #####

  def has_selected?
    selected?
  end

  def selected?
    itineraries.valid.selected.count > 0
  end

  # Returns the itinerary selected for this trip.  If one isn't selected, returns nil
  def selected_itinerary
    if selected?
      return itineraries.valid.selected.first
    else
      return nil
    end
  end

  # Converts the trip date and time into a date time object
  def trip_time
    # puts scheduled_date.ai
    # puts scheduled_time.ai
    # DateTime.new(scheduled_date.year, scheduled_date.month, scheduled_date.day,
    #   scheduled_time.hour, scheduled_time.min, 0, scheduled_time.offset)
    scheduled_time
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

  def remove_existing_itineraries(modes = [])
    if modes.empty?
      itineraries.destroy_all
    else
      itins = itineraries.where('mode_id in (?)', modes.pluck(:id))
      itins.destroy_all
    end
  end

  # Generates itineraries for this trip part. Any existing itineraries should have been removed
  # before this method is called.
  def create_itineraries(modes = trip.desired_modes)

    Rails.logger.info "CREATE: " + modes.collect {|m| m.code}.join(",")
    # remove_existing_itineraries
    itins = []

    modes.each do |mode|

      Rails.logger.info('CREATING ITINERARIES FOR TRIP PART ' + self.id.to_s)
      Rails.logger.info(mode)
      case mode
        # start with the non-OTP modes
      when Mode.taxi
        timed "taxi" do
          taxi_itineraries = TaxiItinerary.get_taxi_itineraries(self, from_trip_place, to_trip_place, trip_time, trip.user)
          itins << taxi_itineraries if taxi_itineraries.length > 0
          itins.flatten!
        end
      when Mode.paratransit
        timed "paratransit" do
          itins += ParatransitItinerary.get_itineraries(self)
        end
      when Mode.rideshare
        timed "rideshare" do
          itins += create_rideshare_itineraries
        end
      when Mode.ride_hailing
        timed "ride_hailing" do
          itins += RideHailingItinerary.get_itineraries(self)
        end
      else
        # OTP modes
        if (!mode.otp_mode.blank?)
          # Transit modes + Bike, Drive, Walk
          timed "fixed" do
            new_itins = create_fixed_route_itineraries(mode.otp_mode, mode)
            non_duplicate_itins = []
            new_itins.each do |itin|
              unless self.check_for_duplicates(itin, self.itineraries + itins)
                non_duplicate_itins << itin
              end
            end
            itins += non_duplicate_itins
          end
        end
      end
    end
    Rails.logger.info('Adding NEW ITINERARIES TO THIS TRIP PART')
    Rails.logger.info(itins.inspect)
    self.itineraries << itins
    itins
  end

  def check_for_duplicates(new_i, existing_itins)
    #Removes Duplicate Walk Trips.
    unless new_i.is_walk
      return false
    end

    existing_itins.each do |itin|
      if itin.is_walk
         return true
      end
    end

    false
  end

  def timed label, &block
    s = Time.now
    yield block
    s2 = Time.now
    Rails.logger.info "TIMING: #{label} #{s2 - s} #{s} #{s2}"
  end

  def create_fixed_route_itineraries(mode="TRANSIT,WALK", mode_code='mode_transit')
    itins = []
    tp = TripPlanner.new
    arrive_by = !is_depart
    wheelchair = (trip.user.requires_wheelchair_access? and Oneclick::Application.config.transit_respects_ada).to_s

    default_walk_speed = WalkingSpeed.where(is_default:true).first
    default_walk_max_dist = WalkingMaximumDistance.where(is_default:true).first
    walk_speed = default_walk_speed ? default_walk_speed.value : 3.0
    max_walk_distance = default_walk_max_dist ? default_walk_max_dist.value : 2.0

    # SET THE WALKING SPEED
    #Check to see if the trip has a walking_speed
    if trip.walk_mph
      walk_speed = trip.walk_mph
    #If the trip doesn't have a walk speed, check to see if the user does
    elsif trip.user.walking_speed
      walk_speed = trip.user.walking_speed.value
    end

    # SET MAX WALK DISTANCE
    #Check to see if the trip has a maximum distance
    if trip.max_walk_miles
      max_walk_distance = trip.max_walk_miles
    #If the trip doesn't have a max walk distance, check to see if the user does
    elsif trip.user.walking_maximum_distance
      max_walk_distance = trip.user.walking_maximum_distance.value
    end

    # If the max walk time is shorter than the distance allows, override the distance
    # Check to see if the trip has a maximum walk time
    if trip.max_walk_seconds
      if (trip.max_walk_seconds.to_f * (1.0/3600.0) * walk_speed.to_f) < max_walk_distance
        max_walk_distance = (trip.max_walk_seconds.to_f * (1.0/3600.0) * walk_speed.to_f)
      end
    end

    result, response = tp.get_fixed_itineraries([from_trip_place.location.first, from_trip_place.location.last],[to_trip_place.location.first, to_trip_place.location.last], trip_time, arrive_by.to_s, mode, wheelchair, walk_speed, max_walk_distance, self.trip.max_bike_miles, self.trip.optimize, self.trip.num_itineraries)

    #TODO: Save errored results to an event log
    if result
      tp.convert_itineraries(response, mode_code).each do |itinerary|

        #If the max_walk is an absolute and it's above the max walk time, then discard it
        if Oneclick::Application.config.max_walk_seconds_is_constraint and itinerary['walk_time'].to_f > (trip.max_walk_seconds || Oneclick::Application.config.max_walk_seconds)
          next
        end

        # Discard if it's associated with an inactive service
        next if itinerary['service'] && !itinerary['service']['active']

        serialized_itinerary = {}
        itinerary.each do |k,v|
          if v.is_a? Array
            serialized_itinerary[k] = v.to_yaml
          else
            serialized_itinerary[k] = v
          end
        end

        itins << Itinerary.new(serialized_itinerary)

      end
    end

    #Check to see special fare rules exist
    fh = FareHelper.new
    itins.each do |itin|
      fh.calculate_fixed_route_fare(self, itin)
    end

    #Filter impractical routes
    if mode == 'TRANSIT,WALK' and result
      itins = check_for_long_walks(itins)
    elsif (mode == 'CAR,TRANSIT,WALK' or mode == 'CAR_PARK,TRANSIT,WALK') and result
      itins = check_for_short_drives(itins)
    end

    # Filter out itineraries that occur on different days than requested
    if Oneclick::Application.config.filter_midnight
      itins = filter_midnight(itins)
    end

    # Filter out trips with very long waits
    if Oneclick::Application.config.filter_long_wait
      itins = filter_long_wait(itins)
    end

    itins
  end

  # Filter trips that begin/end on a different day than they were planned to begin/end
  def filter_midnight itineraries
    if self.is_depart
      # Filter out itineraries that begin on a different day than requested
      return itineraries.select {|itin| itin.start_time.day == self.scheduled_time.day}
    else
      # Filter out itineraries that end on a different day than requested
      return itineraries.select {|itin| itin.end_time.day == self.scheduled_time.day}
    end
  end

  def filter_long_wait itineraries
    return itineraries.select { |itin| itin.wait_time < Oneclick::Application.config.absolute_max_wait_minutes*90}
  end

  # TODO refactor following 4 methods
  def check_for_long_walks itineraries

    filtered = []
    replaced = false
    itineraries.each do |itinerary|

      ### Check to see where the long walks are
      legs = itinerary.get_legs

      first_leg = legs.first
      last_leg = legs.last

      multiple_long_walks = false
      long_first_leg = false
      long_last_leg = false

      if first_leg.mode == 'WALK' and first_leg.duration > Oneclick::Application.config.max_walk_seconds
        long_first_leg = true
      end

      if last_leg.mode == 'WALK' and last_leg.duration > Oneclick::Application.config.max_walk_seconds
        long_last_leg = true
      end

      if long_last_leg and long_first_leg
        multiple_long_walks =  true
      end

      unless multiple_long_walks
        legs[1...-1].each do |leg|
          if leg.mode == 'WALK' and leg.duration > Oneclick::Application.config.max_walk_seconds and (long_first_leg or long_last_leg)
            multiple_long_walks = true
            break
          end
        end
      end

      # Handle multiple long walks
      if multiple_long_walks
        if Oneclick::Application.config.replace_long_walks
          itinerary.hide
        end

        if Mode.car.active? and not replaced
          filtered += create_fixed_route_itineraries("CAR")
          replaced = true
        end

      # Handle long walks on the first leg
      elsif long_first_leg
        if Oneclick::Application.config.replace_long_walks
          itinerary.hide
        end

        if Mode.car_transit.active?
          tp = TripPlanner.new
          new_itinerary = itinerary.dup

          legs = new_itinerary.get_legs
          replaced_leg = legs.first

          ##Build a short drive itinerary
          result, response = tp.get_fixed_itineraries([replaced_leg.start_place.lat, replaced_leg.start_place.lon], [replaced_leg.end_place.lat, replaced_leg.end_place.lon], replaced_leg.end_time,
                                                      'true', mode="CAR", wheelchair='false', walk_speed=3, max_walk_distance=1000, max_bicycle_distance=5, self.trip.optimize, self.trip.num_itineraries)

          #TODO: Save errored results to an event log
          if result
            tp.convert_itineraries(response, Mode.car.code).each do |itinerary|

              serialized_itinerary = {}
              itinerary.each do |k,v|
                if v.is_a? Array
                  serialized_itinerary[k] = v.to_yaml
                else
                  serialized_itinerary[k] = v
                end
              end

              #Adjust itinerary
              car_itin = Itinerary.new(serialized_itinerary)

              #walk_time, walk duration, total duration
              first_leg = new_itinerary.get_legs.first
              new_itinerary.walk_time -= first_leg.duration
              new_itinerary.walk_distance -= first_leg.distance
              new_itinerary.duration -= (first_leg.duration - car_itin.duration)
              new_itinerary.start_time = new_itinerary.start_time + (first_leg.duration - car_itin.duration)

              #legs
              yaml_legs = YAML.load(new_itinerary.legs)
              yaml_legs = yaml_legs.drop(1)
              yaml_car = YAML.load(car_itin.legs)
              yaml_legs = yaml_car + yaml_legs
              new_itinerary.legs = yaml_legs.to_yaml
              new_itinerary.update_legs

              filtered << new_itinerary

            end
          end
        end

      # Handle long walks on the last leg
      elsif long_last_leg
        if Oneclick::Application.config.replace_long_walks
          itinerary.hide
        end

        if Mode.car_transit.active?
          tp = TripPlanner.new
          new_itinerary = itinerary.dup

          legs = new_itinerary.get_legs
          replaced_leg = legs.last
          legs = legs[0...-1]

          ##Build a short drive itinerary
          result, response = tp.get_fixed_itineraries([replaced_leg.start_place.lat, replaced_leg.start_place.lon], [replaced_leg.end_place.lat, replaced_leg.end_place.lon], replaced_leg.start_time,
                                                      'false', mode="CAR", wheelchair='false', walk_speed=3, max_walk_distance=1000, max_bicycle_distance=5, self.trip.optimize, self.trip.num_itineraries)

          #TODO: Save errored results to an event log
          if result
            tp.convert_itineraries(response, Mode.car.code).each do |itinerary|
              serialized_itinerary = {}

              itinerary.each do |k,v|
                if v.is_a? Array
                  serialized_itinerary[k] = v.to_yaml
                else
                  serialized_itinerary[k] = v
                end
              end

              #Adjust itinerary
              car_itin = Itinerary.new(serialized_itinerary)

              #walk_time, walk duration, total duration
              last_leg = new_itinerary.get_legs.last
              new_itinerary.walk_time -= last_leg.duration
              new_itinerary.walk_distance -= last_leg.distance
              new_itinerary.duration -= (last_leg.duration - car_itin.duration)
              new_itinerary.end_time = new_itinerary.end_time - (last_leg.duration - car_itin.duration)

              #legs
              yaml_legs = YAML.load(new_itinerary.legs)
              yaml_legs = yaml_legs[0...-1]
              yaml_car = YAML.load(car_itin.legs)
              yaml_legs += yaml_car
              new_itinerary.legs = yaml_legs.to_yaml
              new_itinerary.update_legs

              filtered << new_itinerary

            end
          end
        end
      end

      filtered << itinerary

    end

    filtered
  end

  def check_for_short_drives itineraries
    filtered = []
    itineraries.each do |itinerary|
      first_leg = itinerary.get_legs.first
      unless first_leg.mode == 'CAR' and first_leg.duration < Oneclick::Application.config.min_drive_seconds
        filtered << itinerary
      end
    end

    filtered
  end

  # Note not called for now.
  # See https://www.pivotaltracker.com/story/show/71254872
  def hide_duplicate_fixed_route itineraries
    seen = {}
    itineraries.each do |i|
      if i.mode.nil?
        Rails.logger.info "hide_duplicate_fixed_route"
        Rails.logger.info "Skipping itinerary because mode is nil: #{i.ai}"
        next
      end
      mar = i.mode_and_routes
      i.hide if seen[mar]
      seen[mar] = true
    end
  end

  def create_rideshare_itineraries
    itins = []
    tp = TripPlanner.new
    trip.restore_trip_places_georaw
    result, response = tp.get_rideshare_itineraries(from_trip_place, to_trip_place, trip_time)
    if result
      itinerary = tp.convert_rideshare_itineraries(response)
      unless ENV['SKIP_DYNAMIC_RIDESHARE_DURATION']
        begin
          base_duration = TripPlanner.new.get_drive_time(!is_depart, trip_time, from_trip_place.location.first,
            from_trip_place.location.last, to_trip_place.location.first, to_trip_place.location.last)[0]
        rescue Exception => e
          Rails.logger.error "Exception #{e} while getting trip duration."
          base_duration = nil
        end
      else
        Rails.logger.info "SKIP_DYNAMIC_RIDESHARE_DURATION is set, skipping it"
      end
      i = Itinerary.new(itinerary)
      service_window = i.service.service_window if i && i.service
      i.estimate_duration(base_duration, Oneclick::Application.config.minimum_rideshare_duration, Oneclick::Application.config.rideshare_duration_factor, service_window, trip_time, is_depart)
      itins << i
    else
      itins << Itinerary.new('server_status'=>500, 'server_message'=>response.to_s,
                                        'mode' => Mode.rideshare)
    end
    itins
  end

  def max_notes_count
    itineraries.valid.visible.map(&:notes_count).max
  end

  def reschedule minutes
    new_time = scheduled_time + (minutes.to_i).minutes

    if new_time < DateTime.current.utc
      raise TranslationEngine.translate_text(:cannot_change_time_to_past)
    end
=begin
if only trip part, is okay
if advancing, just make sure doesn't equal or get later than next part's time
if subtracting, just make sure doesn't get equal to or earlier than previous part's time
=end
    if not new_time_before_next_part(new_time)
      raise TranslationEngine.translate_text(:cannot_change_time_to_after_next_trip_part)
    elsif not new_time_after_prev_part(new_time)
      raise TranslationEngine.translate_text(:cannot_change_time_to_before_prev_trip_part)
    end

    update_attribute(:scheduled_time, new_time)
    trip.update_attribute(:scheduled_time, new_time)
    # only do this is we successfully changed the time
    remove_existing_itineraries
  end

  def new_time_before_next_part new_time
    return true if trip.trip_parts.count==1
    return true if sequence==(trip.trip_parts.count-1)
    trip.next_part(self).scheduled_time
    return new_time < trip.next_part(self).scheduled_time
  end

  def new_time_after_prev_part new_time
    return true if trip.trip_parts.count==1
    return true if sequence==0
    return new_time > trip.prev_part(self).scheduled_time
  end

  def unselect
    selected_itinerary = self.selected_itinerary
    if selected_itinerary
      selected_itinerary.selected = false
      selected_itinerary.save
    end
  end

  def origin
    return self.from_trip_place
  end

  def destination
    return self.to_trip_place
  end

  # Returns true/false if trip_part falls within bounds of passed schedule
  def valid_for_schedule?(schedule)
    tt = trip_time.seconds_since_midnight
    tdow = trip_time.wday
    sdow = schedule.day_of_week

    # Handles special case for midnight trips--check previous day's schedule as necessary.
    (tdow == sdow && schedule.contains?(tt)) ||
    (tt == 0 && tdow == (sdow + 1) % 7 && schedule.contains?(tt + 24 * 3600))
  end

  # Returns true/false if trip_part is valid for any of the passed service's schedules
  # Returns true if passed a nil service, or a service with no schedules
  def valid_for_service_time?(service)

    # Check to see if user is whitelisted
    user_service = self.trip.user.user_profile.user_services.find_by(service: service)
    if user_service and user_service.unrestricted_hours
      return true
    end

    return true if service.nil? or service.schedules.count == 0
    service.schedules.any? { |sched| valid_for_schedule?(sched) }
  end
end
