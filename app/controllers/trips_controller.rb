class TripsController < TravelerAwareController

  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :destroy]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  FROM_PLACES_SESSION_KEY = 'trips_from_places'
  TO_PLACES_SESSION_KEY = 'trips_to_places'
  
  TRIP_DATE_FORMAT_STRING = "%m/%d/%Y"
  TRIP_TIME_FORMAT_STRING = "%-I:%M %P"
    
  MODE_NEW = "1"
  MODE_EDIT = "2"
  MODE_REPEAT = "3"
    
  # User wants to repeat a trip  
  def repeat
    # set the @traveler variable
    get_traveler
    # set the @trip variable
    get_trip

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_REPEAT

    # Set the travel time/date to the default
    travel_date = default_trip_time
    
    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)
        
    respond_to do |format|
      format.html { render :action => 'edit'}
    end
  end

  # User wants to edit a trip in the future  
  def edit
    # set the @traveler variable
    get_traveler
    # set the @trip variable
    get_trip

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_EDIT
        
    respond_to do |format|
      format.html
    end
  end
  
  def unset_traveler

    # set or update the traveler session key with the id of the traveler
    set_traveler_id(nil)
    # set the @traveler variable
    get_traveler
    
    redirect_to root_path, :alert => "Assisting has been turned off."

  end

  def set_traveler

    # set or update the traveler session key with the id of the traveler
    set_traveler_id(params[:trip_proxy][:traveler])
    # set the @traveler variable
    get_traveler

    @trip_proxy = TripProxy.new()
    @trip_proxy.traveler = @traveler

    # Set the travel time/date to the default
    travel_date = default_trip_time

    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)

    respond_to do |format|
      format.html { render :action => 'new'}
      format.json { render json: @trip_proxy }
    end

  end
  
  # GET /trips/1
  # GET /trips/1.json
  def show

    set_no_cache

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end

  end
  
  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide

    # limit itineraries to only those related to trps owned by the user
    itinerary = Itinerary.find(params[:id])
    if itinerary.trip.owner != current_traveler
      render text: t(:unable_to_remove_itinerary), status: 500
      return
    end

    respond_to do |format|
      if itinerary
        @trip = itinerary.trip
        itinerary.hide
        format.js # hide.js.haml
      else
        render text: t(:unable_to_remove_itinerary), status: 500
      end
    end
  end

  # GET /trips/new
  # GET /trips/new.json
  def new

    @trip_proxy = TripProxy.new()
    @trip_proxy.traveler = @traveler

    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_NEW
    
    # Set the travel time/date to the default
    travel_date = default_trip_time

    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

  # POST /trips
  # POST /trips.json
  def create

    @trip_proxy = TripProxy.new(params[:trip_proxy])
    @trip_proxy.traveler = @traveler
  
    # run the validations on the trip proxy. This checks that from place, to place and the 
    # time/date options are all set
    if @trip_proxy.valid?
      # See if the user has selected an poi or a pre-defined place. If not we need to geocode and check
      # to see if multiple addresses are available. The alternate addresses are stored back in the proxy object
      geocoder = OneclickGeocoder.new
      if @trip_proxy.from_place_selected.blank? || @trip_proxy.from_place_selected_type.blank?
        geocoder.geocode(@trip_proxy.from_place)
        # store the results in the session
        session[FROM_PLACES_SESSION_KEY] = encode(geocoder.results)
        @trip_proxy.from_place_results = geocoder.results
        if @trip_proxy.from_place_results.empty?
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :from_place, "No matching places found."
        elsif @trip_proxy.from_place_results.count == 1
          @trip_proxy.from_place_selected = 0
          @trip_proxy.from_place_selected_type = PlacesController::RAW_ADDRESS_TYPE
        else
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :from_place, "Alternate candidate places found."
        end
      end
      # Do the same for the to place
      if @trip_proxy.to_place_selected.blank? || @trip_proxy.to_place_selected_type.blank?
        geocoder.geocode(@trip_proxy.to_place)
        # store the results in the session
        session[TO_PLACES_SESSION_KEY] = encode(geocoder.results)
        @trip_proxy.to_place_results = geocoder.results
        if @trip_proxy.to_place_results.empty?
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :to_place, "No matching places found."
        elsif @trip_proxy.to_place_results.count == 1
          @trip_proxy.to_place_selected = 0
          @trip_proxy.to_place_selected_type = PlacesController::RAW_ADDRESS_TYPE
        else
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :to_place, "Alternate candidate places found."
        end
      end
      # end of validation test
    end
       
    if @trip_proxy.errors.empty?
      @trip = create_trip(@trip_proxy)
    end

    respond_to do |format|
      if @trip
        if @trip.save
          @trip.reload
          @planned_trip = @trip.planned_trips.first
          @planned_trip.create_itineraries
          format.html { redirect_to user_planned_trip_path(@traveler, @planned_trip) }
          format.json { render json: @planned_trip, status: :created, location: @planned_trip }
        else
          format.html { render action: "new" }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "new", flash[:alert] => "One or more addresses need to be fixed." }
      end
    end
  end

protected
  
  # Set the default travel time/date to 30 mins from now
  def default_trip_time
    return Time.now.in_time_zone.next_interval(30.minutes)    
  end
  
  # creates a trip_proxy object from a trip
  def create_trip_proxy (trip)

    # get the planned trip for this trip
    planned_trip = trip.planned_trips.first
    
    # initailize a trip proxy from this trip
    trip_proxy = TripProxy.new
    trip_proxy.traveler = @traveler
    trip_proxy.trip_purpose_id = trip.trip_purpose.id
    trip_proxy.arrive_depart = planned_trip.is_depart
    trip_proxy.trip_date = planned_trip.trip_datetime.strftime(TRIP_DATE_FORMAT_STRING)
    trip_proxy.trip_time = planned_trip.trip_datetime.strftime(TRIP_TIME_FORMAT_STRING)
    
    # Set the from place
    trip_proxy.from_place = trip.trip_places.first
    if trip.trip_places.first.poi
      trip_proxy.from_place_selected_type = POI_TYPE
      trip_proxy.from_place_selected = trip.trip_places.first.poi.id
    elsif trip.trip_places.first.place
      trip_proxy.from_place_selected_type = PLACES_TYPE
      trip_proxy.from_place_selected = trip.trip_places.first.place.id
    else
      trip_proxy.from_place_selected_type = RAW_ADDRESS_TYPE      
    end

    # Set the to place
    trip_proxy.to_place = trip.trip_places.last
    if trip.trip_places.last.poi
      trip_proxy.to_place_selected_type = POI_TYPE
      trip_proxy.to_place_selected = trip.trip_places.last.poi.id
    elsif trip.trip_places.last.place
      trip_proxy.to_place_selected_type = PLACES_TYPE
      trip_proxy.to_place_selected = trip.trip_places.last.place.id
    else
      trip_proxy.to_place_selected_type = RAW_ADDRESS_TYPE      
    end
    
    return trip_proxy
    
  end
  
  def get_trip
    if user_signed_in?
      # limit trips to trips accessible by the user unless an admin
      if current_user.has_role? :admin
        @trip = Trip.find(params[:id])
      else
        @trip = @traveler.trips.find(params[:id])
      end
    end
  end

private

  def encode(addresses)
    a = []
    addresses.each do |addr|
      a << {
        :address => addr[:street_address],
        :lat => addr[:lat],
        :lon => addr[:lon]
      }
    end
    return a
  end
  

  def create_trip(trip_proxy)

    trip = Trip.new()
    trip.creator = current_or_guest_user
    trip.user = @traveler
    trip.trip_purpose = TripPurpose.find(trip_proxy.trip_purpose_id)

    # get the start for this trip
    from_place = TripPlace.new()
    from_place.sequence = 0
    place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected.to_i, true)
    if place[:poi_id]
      from_place.poi = Poi.find(place[:poi_id])
    elsif place[:place_id]
      from_place.place = @traveler.places.find(place[:place_id])
    else
      from_place.raw_address = place[:address]
      from_place.lat = place[:lat]
      from_place.lon = place[:lon]  
    end

    # get the end for this trip
    to_place = TripPlace.new()
    to_place.sequence = 1
    place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected.to_i, false)
    if place[:poi_id]
      to_place.poi = Poi.find(place[:poi_id])
    elsif place[:place_id]
      to_place.place = @traveler.places.find(place[:place_id])
    else
      to_place.raw_address = place[:address]
      to_place.lat = place[:lat]
      to_place.lon = place[:lon]  
    end

    # add the places to the trip
    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = trip.creator
    planned_trip.is_depart = trip_proxy.arrive_depart == 'departing at' ? true : false
    planned_trip.trip_datetime = trip_proxy.trip_datetime
    planned_trip.trip_status = TripStatus.find_by_name(TripStatus::STATUS_NEW)    
    
    trip.planned_trips << planned_trip

    return trip
  end
  
  # Get the selected place for this trip-end based on the type of place
  # selected and the data for that place
  def get_preselected_place(place_type, place_id, is_from = false)
    
    if place_type == POI_TYPE
      # the user selected a POI using the type-ahead function
      poi = Poi.find(place_id)
      return {:poi_id => poi.id, :name => poi.name, :lat => poi.lat, :lon => poi.lon, :address => poi.address}
    elsif place_type == CACHED_ADDRESS_TYPE
      # the user selected an address from the trip-places table using the type-ahead function
      trip_place = @traveler.trip_places.find(place_id)
      return {:name => trip_place.raw_address, :lat => trip_place.lat, :lon => trip_place.lon, :address => trip_place.raw_address}
    elsif place_type == PLACES_TYPE
      # the user selected a place using the places drop-down
      place = @traveler.places.find(place_id)
      return {:place_id => place.id, :name => place.name, :lat => place.lat, :lon => place.lon, :address => place.address}
    elsif place_type == RAW_ADDRESS_TYPE
      # the user entered a raw address and possibly selected an alternate from the list of possible
      # addresses
      if is_from
        place = session[FROM_PLACES_SESSION_KEY][place_id]
      else
        place = session[TO_PLACES_SESSION_KEY][place_id]
      end
      return {:name => place[:address], :lat => place[:lat], :lon => place[:lon], :address => place[:address]}
    else
      return {}
    end
  end
end
