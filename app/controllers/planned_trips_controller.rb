class PlannedTripsController < TravelerAwareController
        
  # set the @planned_trip and @trip variables before any actions are invoked
  before_filter :get_planned_trip, :except => [:index]

  TIME_FILTER_TYPE_SESSION_KEY = 'planned_trips_time_filter_type'
  
  def email
    Rails.logger.debug "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    Rails.logger.debug email_addresses.inspect
    email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    Rails.logger.debug email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    UserMailer.user_trip_email(email_addresses, @planned_trip, "ARC OneClick Trip Itinerary", from_email).deliver
    respond_to do |format|
      format.html { redirect_to user_planned_trip_url(current_user, @planned_trip), :notice => "An email was sent to #{email_addresses.join(', ')}."  }
      format.json { render json: @planned_trip }
    end
  end
    
  def index

    # Filtering logic. See ApplicationHelper.trip_filters
    if params[:time_filter_type]
      @time_filter_type = params[:time_filter_type]
    else
      @time_filter_type = session[TIME_FILTER_TYPE_SESSION_KEY]
    end
    # if it is still not set use the default
    if @time_filter_type.nil?
      # default is to use the first time period filter in the TimeFilterHelper class
      @time_filter_type = "100"
    end
    # store it in the session
    session[TIME_FILTER_TYPE_SESSION_KEY] = @time_filter_type

    # If the filter is at least 100 is must be a time filter, otherwise it will be a TripPurpose
    if @time_filter_type.to_i >= 100
      actual_filter = @time_filter_type.to_i - 100
      # get the duration for this time filter
      duration = TimeFilterHelper.time_filter_as_duration(actual_filter)      
      @planned_trips = @traveler.planned_trips.scheduled_between(duration.first, duration.last)
    else
      # the filter is a trip purpose
      @planned_trips = @traveler.planned_trips.where('trip_purpose_id = ?', @time_filter_type).order('planned_trips.trip_datetime DESC')
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planned_trips }
    end
    
  end

  def skip

    get_traveler

    @planned_trip = PlannedTrip.find(session[:current_trip_id])
    @planned_trip.create_itineraries
    @path = user_planned_trip_path(@traveler, @planned_trip)
    session[:current_trip_id] =  nil

    respond_to do |format|
      format.html { redirect_to @path }
    end
  end


  # GET /trips/1
  # GET /trips/1.json
  def show
    # See if there is the show_hidden parameter
    @show_hidden = params[:show_hidden]
    @next_itinerary_id = @show_hidden.nil? ? @planned_trip.valid_itineraries.first.id : @planned_trip.itineraries.first.id

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planned_trip }
    end
  end

  def itinerary
    @itinerary = @planned_trip.valid_itineraries.find(params[:itin])
    @legs = @itinerary.get_legs
    if @itinerary.mode.name.downcase == 'transit'      
      @markers = create_markers(@itinerary, @legs)
      @polylines = create_polylines(@legs)
    end
    
    #Rails.logger.debug @itinerary.inspect
    #Rails.logger.debug @markers.inspect    
    #Rails.logger.debug @polylines.inspect

    respond_to do |format|
      format.js 
    end
    
  end
  
  # GET /trips/1
  # GET /trips/1.json
  def details

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planned_trip }
    end

  end

  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide

    itinerary = @planned_trip.valid_itineraries.find(params[:itinerary])
    if itinerary.nil?
      render text: t(:unable_to_remove_itinerary), status: 500
      return
    end

    itinerary.hidden = true
    
    # find the next unhidden itinerary for this planned trip
    @next_itinerary_id = nil
    found = false
    @planned_trip.valid_itineraries.each do |itin|
      # if the found falg is set, this is the itinerary we want
      if found
        @next_itinerary_id = itin.id
        break
      end
      # if this itin is the one we selected then we mark that we found it. The next
      # itinerary is the one we want to identify
      if itin.id == itinerary.id
        found = true
      end
    end
    if @next_itinerary_id.nil? 
      @next_itinerary_id = @planned_trip.valid_itineraries.first.id
    end
    
    respond_to do |format|
      if itinerary.save
        @planned_trip.reload
        format.js # hide.js.haml
      else
        render text: t(:unable_to_remove_itinerary), status: 500
      end
    end
  end

  def unhide_all
    @planned_trip.hidden_itineraries.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_planned_trip_path(@traveler, @planned_trip)   
  end

protected

  # Create an array of map markers suitable for the Leaflet plugin. 
  def create_markers(itinerary, legs)
      
    planned_trip = itinerary.planned_trip
    trip = planned_trip.trip

    markers = []
    place = {:name => trip.from_place.name, :lat => trip.from_place.location.first, :lon => trip.from_place.location.last, :address => trip.from_place.address}
    markers << get_addr_marker(place, 'start', 'startIcon')
    place = {:name => trip.to_place.name, :lat => trip.to_place.location.first, :lon => trip.to_place.location.last, :address => trip.to_place.address}
    markers << get_addr_marker(place, 'stop', 'stopIcon')
    
    if legs
      legs.each do |leg|
        
        place = {:name => leg.start_place.name, :lat => leg.start_place.lat, :lon => leg.start_place.lon, :address => leg.start_place.name}
        markers << get_addr_marker(place, 'start_leg', 'blueIcon')

        place = {:name => leg.end_place.name, :lat => leg.end_place.lat, :lon => leg.end_place.lon, :address => leg.end_place.name}
        markers << get_addr_marker(place, 'start_leg', 'blueIcon')
        
      end
    end
    
    return markers.to_json
  end

  def create_polylines(legs)
      
    polylines = []
    legs.each_with_index do |leg, index|
      polylines << {
        "id" => index,
        "geom" => leg.geometry,
        "options" => get_leg_display_options(leg)
      }
    end
    
    return polylines.to_json
  end

  def get_leg_display_options(leg) 

    if leg.mode == TripLeg::WALK
      a = {"color" => 'red', "width" => "5"}
    elsif leg.mode == TripLeg::BUS
      a = {"color" => 'blue', "width" => "5"}
    elsif leg.mode == TripLeg::SUBWAY
      a = {"color" => 'green', "width" => "5"}
    else
      a = {}
    end
    
    return a
  end
  
  def get_planned_trip

    get_traveler

    if @traveler.has_role? :admin
      planned_trip = PlannedTrip.find(params[:id])
    else
      planned_trip = @traveler.planned_trips.find(params[:id])
    end

    if planned_trip.nil?
      render text: 'Unable to find the record.', status: 500
    else
      @planned_trip = planned_trip
      @trip = @planned_trip.trip
    end
  end

end
