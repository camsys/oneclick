class TripsController < PlaceSearchingController

  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  
  # Format strings for the trip form date and time fields
  TRIP_DATE_FORMAT_STRING = "%m/%d/%Y"
  TRIP_TIME_FORMAT_STRING = "%-I:%M %P"
    
  # Modes for creating/updating new trips
  MODE_NEW = "1"        # Its a new trip from scratch
  MODE_EDIT = "2"       # Editing an existing trip that is in the future
  MODE_REPEAT = "3"     # Repeating an existing trip that is in the past
      
  # User wants to repeat a trip  
  def repeat
    # set the @traveler variable
    get_traveler
    # set the @trip variable
    get_trip

    # make sure we can find the trip we are supposed to be repeating and that it belongs to us. 
    if @trip.nil? 
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_REPEAT

    # Set the travel time/date to the default
    travel_date = default_trip_time
    
    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)
    
    Rails.logger.info @trip_proxy.inspect
    
    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)

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

    # make sure we can find the trip we are supposed to be updating and that it belongs to us. 
    if @trip.nil? 
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_EDIT
    # Set the trip proxy Id to the PK of the trip so we can update it
    @trip_proxy.id = @trip.id

    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)
        
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

    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      format.html { render :action => 'new'}
      format.json { render json: @trip_proxy }
    end

  end
  
  # GET /trips/1
  # GET /trips/1.json
  def show

    set_no_cache

    # make sure we can find the trip we are supposed to be showing and that it belongs to us. 
    if @trip.nil? 
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end

  end
  
  # called when the user wants to delete a trip
  def destroy

    # set the @traveler variable
    get_traveler
    # set the @trip variable
    get_trip

    # make sure we can find the trip we are supposed to be removing and that it belongs to us. 
    if @trip.nil?
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    
    if @trip
      # remove any child objects
      @trip.clean      
      @trip.destroy
      message = t(:trip_was_successfully_removed)
    else
      render text: t(:error_404), status: 404
      return
    end

    respond_to do |format|
      format.html { redirect_to(user_planned_trips_path(@traveler), :flash => { :notice => message}) } 
      format.json { head :no_content }
    end
    
  end
  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide

    # limit itineraries to only those related to trps owned by the user
    itinerary = Itinerary.find(params[:id])
    if itinerary.trip.owner != current_traveler
      render text: t(:unable_to_remove_itinerary), status: 404
      return
    end

    respond_to do |format|
      if itinerary
        @trip = itinerary.trip
        itinerary.hide
        format.js # hide.js.haml
      else
        render text: t(:unable_to_remove_itinerary), status: 404
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

    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

  # updates a trip
  def update

    # set the @traveler variable
    get_traveler
    # set the @trip variable
    get_trip

    # make sure we can find the trip we are supposed to be updating and that it belongs to us. 
    if @trip.nil?
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_planned_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    
    # Get the updated trip proxy from the form params
    @trip_proxy = create_trip_proxy_from_form_params
    # save the id of the trip we are updating
    @trip_proxy.id = @trip.id

    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)
    
    # see if we can continue saving this trip                
    if @trip_proxy.errors.empty?
      # remove any child objects
      @trip.clean      
      @trip.save
      # Start updating the trip from the form-based one

      # create a trip from the trip proxy
      updated_trip = create_trip(@trip_proxy)
      # update the associations      
      @trip.trip_purpose = updated_trip.trip_purpose
      @trip.creator = @traveler      
      updated_trip.trip_places.each do |tp|
        tp.trip = @trip
        @trip.trip_places << tp
      end
      updated_trip.planned_trips.each do |pt|
        pt.trip = @trip
        @trip.planned_trips << pt
      end
    end

    respond_to do |format|
      if updated_trip # only created if the form validated and there are no geocoding errors
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
        format.html { render action: "new", flash[:alert] => t(:correct_errors_to_create_a_trip) }
      end
    end
    
  end
  
  # POST /trips
  # POST /trips.json
  def create

    # inflate a trip proxy object from the form params
    @trip_proxy = create_trip_proxy_from_form_params
       
    if @trip_proxy.valid?
      @trip = create_trip(@trip_proxy)
    end

    # Create makers for the map control
    @markers = create_markers(@trip_proxy)
    @places = create_place_markers(@traveler.places)

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
        format.html { render action: "new", flash[:alert] => t(:correct_errors_to_create_a_trip) }
      end
    end
  end

protected
  
  # Set the default travel time/date to 30 mins from now
  def default_trip_time
    return Time.now.in_time_zone.next_interval(30.minutes)    
  end
  
  
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    if @traveler.has_role? :admin
      @trip = Trip.find(params[:id])
    else
      begin
        @trip = @traveler.trips.find(params[:id])
      rescue => ex
        Rails.logger.info ex.message
        @trip = nil
      end
    end
  end

  # Create an array of map markers suitable for the Leaflet plugin. If the trip proxy is from an existing trip we will
  # have 
  def create_markers(trip_proxy)
    markers = []
    if trip_proxy.from_place_selected
      place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected.to_i, true)
    else
      place = {:name => trip_proxy.from_place, :lat => trip_proxy.from_lat, :lon => trip_proxy.from_lon, :address => trip_proxy.from_raw_address}
    end
    markers << get_addr_marker(place, 'start', 'startIcon')
    
    if trip_proxy.to_place_selected
      place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected.to_i, false)
    else
      place = {:name => trip_proxy.to_place, :lat => trip_proxy.to_lat, :lon => trip_proxy.to_lon, :address => trip_proxy.to_raw_address}
    end
    
    markers << get_addr_marker(place, 'stop', 'stopIcon')
    return markers.to_json
  end
  
  def create_place_markers(places)
    markers = []    
    places.each_with_index do |place, index|
      markers << get_map_marker(place, place.id, 'startIcon')
    end
    return markers
  end
private
  
  # creates a trip_proxy object from form parameters
  def create_trip_proxy_from_form_params

    trip_proxy = TripProxy.new(params[:trip_proxy])
    trip_proxy.traveler = @traveler
  
    return trip_proxy
        
  end
  
  
  # creates a trip_proxy object from a trip. Note that this does not set the
  # trip id into the proxy as only edit functions need this.
  def create_trip_proxy(trip)

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
    trip_proxy.from_place = trip.trip_places.first.name
    trip_proxy.from_raw_address = trip.trip_places.first.address
    trip_proxy.from_lat = trip.trip_places.first.location.first
    trip_proxy.from_lon = trip.trip_places.first.location.last
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
    trip_proxy.to_place = trip.trip_places.last.name
    trip_proxy.to_raw_address = trip.trip_places.last.address
    trip_proxy.to_lat = trip.trip_places.last.location.first
    trip_proxy.to_lon = trip.trip_places.last.location.last
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

  # Creates a trip object from a trip proxy
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
        place = get_cached_addresses(CACHED_FROM_ADDRESSES_KEY)[place_id]
      else
        place = get_cached_addresses(CACHED_TO_ADDRESSES_KEY)[place_id]
      end
      return {:name => place[:name], :lat => place[:lat], :lon => place[:lon], :address => place[:formatted_address]}
    else
      return {}
    end
  end
end
