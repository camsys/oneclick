class TripsController < TravelerAwareController
  
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :destroy]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  FROM_PLACES_SESSION_KEY = 'trips_from_places'
  TO_PLACES_SESSION_KEY = 'trips_to_places'
  
  def index

    # params needed for the subnav filters
    if params[:time_filter_type]
      @time_filter_type = params[:time_filter_type]
    else
       @time_filter_type = session[TIME_FILTER_TYPE_SESSION_KEY]
    end
    # if it is still not set use the default
    if @time_filter_type.nil?
      @time_filter_type = "0"
    end
    # store it in the session
    session[TIME_FILTER_TYPE_SESSION_KEY] = @time_filter_type

    # get the duration for this time filter
    duration = TimeFilterHelper.time_filter_as_duration(@time_filter_type)
    
    if user_signed_in?
      @trips = @traveler.trips.created_between(duration.first, duration.last).order("created_at DESC")
    else
      redirect_to error_404_path   
      return 
    end
 
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trips }
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
    # Set the default travel time/date to tomorrow plus 30 mins from now
    travel_date = Time.now.tomorrow + 30.minutes
    @trip_proxy.trip_date = travel_date.strftime("%m/%d/%Y")
    @trip_proxy.trip_time = travel_date.strftime("%I:%M %P")

    respond_to do |format|
      format.html { render :action => 'new'}
      format.json { render json: @trip }
    end
        
  end
  
  # GET /trips/1
  # GET /trips/1.json
  def show
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end

  end

  # GET /trips/new
  # GET /trips/new.json
  def new
    
    @trip_proxy = TripProxy.new()
    @trip_proxy.traveler = @traveler
    # Set the default travel time/date to tomorrow plus 30 mins from now
    travel_date = Time.now.tomorrow + 30.minutes
    @trip_proxy.trip_date = travel_date.strftime("%m/%d/%Y")
    @trip_proxy.trip_time = travel_date.strftime("%I:%M %P")
    @markers = []
    
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
      # See if the user has selected an alternate address or a pre-defined place. If not we need to geocode and check
      # to see if multiple addresses are available. The alternate addresses are stored back in the proxy object
      geocoder = OneclickGeocoder.new
      if @trip_proxy.from_place_selected.blank?
        geocoder.geocode(@trip_proxy.from_place)
        # store the results in the session
        session[FROM_PLACES_SESSION_KEY] = encode(geocoder.results)
        @trip_proxy.from_place_results = geocoder.results
        if @trip_proxy.from_place_results.count == 1
          @trip_proxy.from_place_selected = 0
          @trip_proxy.from_place_selected_type = 0
        else
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :from_place, "Alternate places found."
        end
      end
      # Do the same for the to place
      if @trip_proxy.to_place_selected.blank?
        geocoder.geocode(@trip_proxy.to_place)
        # store the results in the session
        session[TO_PLACES_SESSION_KEY] = encode(geocoder.results)
        @trip_proxy.to_place_results = geocoder.results
        if @trip_proxy.to_place_results.count == 1
          @trip_proxy.to_place_selected = 0
          @trip_proxy.to_place_selected_type = 0
        else
          # the user needs to select one of the alternatives
          @trip_proxy.errors.add :to_place, "Alternate places found."
        end
      end
      # end of validation test
    end
       
    if @trip_proxy.errors.empty?
      if user_signed_in?
        @trip = create_authenticated_trip(@trip_proxy)
      else
        @trip = create_anonymous_trip(@trip_proxy)
      end
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
  
  def create_authenticated_trip(trip_proxy)

    trip = Trip.new()
    trip.creator = current_user
    trip.user = @traveler
        
    # get the from place from the proxy
    selected_id = trip_proxy.from_place_selected.to_i
    # see if we are selecting a raw-address or a pre-defined type
    selected_id_type = trip_proxy.from_place_selected_type

    from_place = TripPlace.new()
    from_place.sequence = 0

    if selected_id_type == "0"
      # raw address
      address = session[FROM_PLACES_SESSION_KEY][selected_id]
      # the address format comes from the oneclick geocoder
      from_place.raw_address = address[:address]
      from_place.lat = address[:lat]
      from_place.lon = address[:lon]  
    else
      selected_from_place = @traveler.places.find(selected_id)
      from_place.place = selected_from_place
    end
    
    # get the to place from the proxy
    selected_id = trip_proxy.to_place_selected.to_i
    selected_id_type = trip_proxy.to_place_selected_type

    to_place = TripPlace.new()
    to_place.sequence = 1

    if selected_id_type == "0"
      # raw address
      address = session[TO_PLACES_SESSION_KEY][selected_id]
      # the address format comes from the oneclick geocoder
      to_place.raw_address = address[:address]
      to_place.lat = address[:lat]
      to_place.lon = address[:lon]  
    else
      selected_to_place = @traveler.places.find(selected_id)
      to_place.place = selected_to_place
    end
        
    # add the places to the trip
    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = trip.creator
    planned_trip.is_depart = trip_proxy.arrive_depart == 'departing at' ? true : false
    planned_trip.trip_datetime = trip_proxy.trip_datetime
    planned_trip.trip_status = TripStatus.find(1)    
    
    trip.planned_trips << planned_trip

    return trip

  end

  def create_anonymous_trip(trip_proxy)

    trip = Trip.new()
    trip.creator = current_or_guest_user
    trip.user = current_or_guest_user
        
    # get the from place from the proxy
    selected_id = trip_proxy.from_place_selected.to_i
    address = session[FROM_PLACES_SESSION_KEY][selected_id]
   
    from_place = TripPlace.new()
    from_place.sequence = 0
    # the address format comes from the oneclick geocoder
    from_place.raw_address = address[:address]
    from_place.lat = address[:lat]
    from_place.lon = address[:lon]  

    # get the to place from the proxy
    selected_id = trip_proxy.to_place_selected.to_i
    address = session[TO_PLACES_SESSION_KEY][selected_id]

    to_place = TripPlace.new()
    to_place.sequence = 1
    # the address format comes from the oneclick geocoder
    to_place.raw_address = address[:address]
    to_place.lat = address[:lat]
    to_place.lon = address[:lon]    
        
    # add the places to the trip
    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = trip.creator
    planned_trip.is_depart = trip_proxy.arrive_depart == 'departing at' ? true : false
    planned_trip.trip_datetime = trip_proxy.trip_datetime
    planned_trip.trip_status = TripStatus.find(1)    
    
    trip.planned_trips << planned_trip

    return trip
    
  end
  #
  # generate an array of map markers for use with the leaflet plugin
  #
  def generate_map_markers(addresses)
    objs = []
    addresses.each do |addr|
      objs << get_map_marker(addr)
    end
    return objs.to_json
  end

  # create an place map marker
  def get_map_marker(addr)
    {
      "id" => addr.id,
      "lat" => addr.lat,
      "lng" => addr.lon,
      "name" => addr.name,
      "iconClass" => 'greenIcon',
      "title" => addr.formatted_address,
      "description" => render_to_string(:partial => "/trips/address_popup", :locals => { :address => addr })
    }
  end

end
