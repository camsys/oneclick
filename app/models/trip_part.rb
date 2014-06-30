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
    if is_return_trip?
      nil
    else
      trip.return_part
    end
  end

  def is_bookable?
    selected? and selected_itinerary.is_bookable?
  end

  def is_booked?
    selected? and selected_itinerary.booking_confirmation
  end

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
      itineraries.where('mode_id in (?)', modes.pluck(:id)).destroy_all
    end
  end

  # Generates itineraries for this trip part. Any existing itineraries should have been removed
  # before this method is called.
  def create_itineraries(modes = trip.desired_modes)
    Rails.logger.info "CREATE: " + modes.collect {|m| m.code}.join(",")
    # remove_existing_itineraries
    itins = []

    modes.each do |mode|
      case mode
        # start with the non-OTP modes
      when Mode.taxi
        timed "taxi" do
          itins += create_taxi_itineraries
        end
      when Mode.paratransit
        timed "paratransit" do
          itins += create_paratransit_itineraries
        end
      when Mode.rideshare
        timed "rideshare" do
          itins += create_rideshare_itineraries
        end
      else
        # OTP modes
        if (!mode.otp_mode.blank?)
          # Transit modes + Bike, Drive, Walk
          timed "fixed" do
            itins += create_fixed_route_itineraries mode.otp_mode
          end
        end
      end
    end
      
    self.itineraries << itins
    itins
  end

  def timed label, &block
    s = Time.now
    yield block
    s2 = Time.now
    Rails.logger.info "TIMING: #{label} #{s2 - s} #{s} #{s2}"
  end

  # TODO refactor following 4 methods
  def create_fixed_route_itineraries(mode="TRANSIT,WALK")
    itins = []
    tp = TripPlanner.new
    arrive_by = !is_depart
    wheelchair = trip.user.requires_wheelchair_access?.to_s
    result, response = tp.get_fixed_itineraries([from_trip_place.location.first, from_trip_place.location.last],[to_trip_place.location.first, to_trip_place.location.last], trip_time, arrive_by.to_s, mode, wheelchair)

    #TODO: Save errored results to an event log
    if result
      tp.convert_itineraries(response).each do |itinerary|
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

    if mode == 'TRANSIT,WALK' and result
      itins += check_for_long_walks(itins)
    end

    # Don't hide duplicate itineraries in new UI
    # See https://www.pivotaltracker.com/story/show/71254872
    # TODO This will probably break kiosk, will add story
    # hide_duplicate_fixed_route(itineraries)
    itins
  end

  def check_for_long_walks itineraries
    long_walks = false
    itineraries.each do |itinerary|
      first_leg = itinerary.get_legs.first
      #TODO: Make the 20 minute threshold configurable.
      if first_leg.mode == 'WALK' and first_leg.duration > 1200
        long_walks = true
        itinerary.hide
      end
    end
    if long_walks
      itins = []

      #KISS N RIDE
      itins += create_fixed_route_itineraries('CAR,TRANSIT,WALK')

      #PARK N RIDE
      itins += create_fixed_route_itineraries("CAR_PARK,TRANSIT,WALK")

      return itins
    end
    return []
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

  def create_taxi_itineraries
    itins = []
    tp = TripPlanner.new
    result, response = tp.get_taxi_itineraries([from_trip_place.location.first, from_trip_place.location.last],[to_trip_place.location.first, to_trip_place.location.last], trip_time)
    if result
      itinerary = tp.convert_taxi_itineraries(response)
      itinerary['server_message'] = itinerary['server_message'].to_yaml if itinerary['server_message'].is_a? Array
      itins << Itinerary.new(itinerary)
    else
      itins << Itinerary.new('server_status'=>500, 'server_message'=>response.to_s)
    end
    itins
  end

  def create_paratransit_itineraries
    eh = EligibilityService.new
    fh = FareHelper.new
    itins = eh.get_accommodating_and_eligible_services_for_traveler(self)
    itins = eh.get_eligible_services_for_trip(self, itins)

    itins = itins.collect do |itinerary|
      new_itinerary = Itinerary.new(itinerary)
      new_itinerary.trip_part = self
      fh.calculate_fare(self, new_itinerary)
      new_itinerary
    end

    unless itins.empty?
      unless ENV['SKIP_DYNAMIC_PARATRANSIT_DURATION']
        begin
          base_duration = TripPlanner.new.get_drive_time(!is_depart, trip_time, from_trip_place.location.first,
            from_trip_place.location.last, to_trip_place.location.first, to_trip_place.location.last)
        rescue Exception => e
          Rails.logger.error "Exception #{e} while getting trip duration."
          base_duration = nil
        end
      else
        Rails.logger.info "SKIP_DYNAMIC_PARATRANSIT_DURATION is set, skipping it"
      end
      Rails.logger.info "Base duration: #{base_duration} minutes"
      itins.each do |i|
        i.estimate_duration(base_duration, Oneclick::Application.config.minimum_paratransit_duration, Oneclick::Application.config.minimum_paratransit_duration, trip_time, is_depart)
      end
    end
    itins
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
            from_trip_place.location.last, to_trip_place.location.first, to_trip_place.location.last)
        rescue Exception => e
          Rails.logger.error "Exception #{e} while getting trip duration."
          base_duration = nil
        end
      else
        Rails.logger.info "SKIP_DYNAMIC_RIDESHARE_DURATION is set, skipping it"
      end
      i = Itinerary.new(itinerary)
      i.estimate_duration(base_duration, Oneclick::Application.config.minimum_rideshare_duration, Oneclick::Application.config.rideshare_duration_factor, trip_time, is_depart)
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
=begin
if only trip part, is okay
if advancing, just make sure doesn't equal or get later than next part's time
if subtracting, just make sure doesn't get equal to or earlier than previous part's time
=end
    unless new_time_before_next_part(new_time) && new_time_after_prev_part(new_time)
      raise "Cannot change trip part time, after/before adjacent trip part"
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

end
