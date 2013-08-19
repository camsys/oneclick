class TripsController < ApplicationController
  
  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
  
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :destroy]
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:new, :create]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  TRAVELER_USER_SESSION_KEY = 'traveler'
  
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
      @trips = current_traveler.trips.created_between(duration.first, duration.last).order("created_at DESC")
    else
      redirect_to error_404_path   
      return 
    end
 
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trips }
    end
    
  end

  def set_traveler
    
    # update the session with the traveler id
    session[TRAVELER_USER_SESSION_KEY] = params[:trip_proxy][:traveler]
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
    
    if user_signed_in?
      @trip = create_authenticated_trip(@trip_proxy)
    else
      @trip = create_anonymous_trip(@trip_proxy)
    end
    
    respond_to do |format|
      if @trip.save
        @trip.reload
        @planned_trip = @trip.planned_trips.first
        @planned_trip.create_itineraries
        if @planned_trip.valid_itineraries.empty?
          message = t(:trip_created_no_valid_options)
          details = @planned_trip.itineraries.collect do |i|
            "<li>%s (%s)</li>" % [i.server_message, i.server_status]
          end
          message = message + '<ol>' + details.join + '</ol>'
          flash[:error] = message.html_safe
        end
        format.html { redirect_to user_planned_trip_path(@traveler, @planned_trip) }
        format.json { render json: @planned_trip, status: :created, location: @planned_trip }
      else
        format.html { render action: "new" }
        format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
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
        @trip = current_traveler.trips.find(params[:id])
      end
    end
  end

  def get_traveler

    if user_signed_in?
      if session[TRAVELER_USER_SESSION_KEY].blank?
        @traveler = current_user
      else
        @traveler = current_user.travelers.find(session[TRAVELER_USER_SESSION_KEY])
      end 
    else
      # will always be a guest user
      @traveler = current_or_guest_user
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
      from_place.poi = myplace.poi unless myplace.poi.nil?
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
      to_place.poi = myplace.poi unless myplace.poi.nil?
    else
      to_place.raw_address = to_address_or_place_name
      to_place.geocode
    end
    trip.trip_places << from_place
    trip.trip_places << to_place

    planned_trip = PlannedTrip.new
    planned_trip.trip = trip
    planned_trip.creator = current_user
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
