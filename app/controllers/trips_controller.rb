class TripsController < TravelerAwareController
  
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :destroy]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  
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
    
    # see if we have selected addresses or not. If not we need to geocode and check
    # to see if multiple addresses are available. The alternate addresses are stored
    # back in the g
    complete = true
    geocoder = OneclickGeocoder.new
    if @trip_proxy.from_place_selected.blank?
      geocoder.geocode(@trip_proxy.from_place)
      @trip_proxy.from_place_results = geocoder.results
      if @trip_proxy.from_place_results.count == 1
        @trip_proxy.from_place_selected = @trip_proxy.from_place_results.first[:raw_address]
      else
        complete = false
      end
    end
    if @trip_proxy.to_place_selected.blank?
      geocoder.geocode(@trip_proxy.to_place)
      @trip_proxy.to_place_results = geocoder.results
      if @trip_proxy.to_place_results.count == 1
        @trip_proxy.to_place_selected = @trip_proxy.to_place_results.first[:raw_address]
      else
        complete = false
      end
    end
   
    if complete
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
          format.html { render action: "new" }
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

  def create_authenticated_trip(trip_proxy)

    trip = Trip.new()
    trip.creator = current_user
    trip.user = @traveler
        
    # get the places from the proxy
    from_place = TripPlace.new()
    from_place.sequence = 0
    from_address_or_place_name = trip_proxy.from_place[:raw_address]
    myplace = @traveler.places.find_by_name(from_address_or_place_name)
    if myplace
      from_place.place = myplace
    else
      from_place.raw_address = from_address_or_place_name
      from_place.geocode
    end
    to_place = TripPlace.new()
    to_place.sequence = 1
    to_address_or_place_name = trip_proxy.to_place[:raw_address]
    myplace = @traveler.places.find_by_name(to_address_or_place_name)
    if myplace
      to_place.place = myplace
    else
      to_place.raw_address = to_address_or_place_name
      to_place.geocode
    end
    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = trip.creator
    planned_trip.is_depart = trip_proxy.arrive_depart == 'arrive_by' ? false : true
    planned_trip.trip_datetime = trip_proxy.trip_datetime
    planned_trip.trip_status = TripStatus.find(1)    
    
    trip.planned_trips << planned_trip
    
    return trip
  end

  def create_anonymous_trip(trip_proxy)

    trip = Trip.new()
    trip.creator = current_or_guest_user
    trip.user = current_or_guest_user
        
    # get the places from the proxy
    from_place = TripPlace.new()
    from_place.sequence = 0
    from_place.raw_address = trip_proxy.from_place

    to_place = TripPlace.new()
    to_place.sequence = 1
    to_place.raw_address = trip_proxy.to_place

    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = trip.creator
    planned_trip.is_depart = trip_proxy.arrive_depart == 'arrive_by' ? false : true
    planned_trip.trip_datetime = trip_proxy.trip_datetime
    planned_trip.trip_status = TripStatus.find(1)    
    
    trip.planned_trips << planned_trip

    return trip
    
  end

end
