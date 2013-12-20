class TripsController < PlaceSearchingController
  include TripsSupport

  # set the @trip variable before any actions are invoked
  before_filter :get_traveler, only: [:show, :new, :email, :email_itinerary, :details, :repeat, :edit, :destroy,
    :update, :skip, :itinerary, :hide, :unhide_all, :select, :email_itinerary2_values, :email2, :create, :show_printer_friendly]
  before_filter :get_trip, :only => [:show, :email, :email_itinerary, :details, :repeat, :edit,
    :destroy, :update, :itinerary, :hide, :unhide_all, :select, :email_itinerary2_values, :email2, :show_printer_friendly]


  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  
  # Format strings for the trip form date and time fields
  TRIP_DATE_FORMAT_STRING = "%m/%d/%Y"
  TRIP_TIME_FORMAT_STRING = "%-I:%M %P"
  
  # Set up configurable defaults
  DEFAULT_RETURN_TRIP_DELAY_MINS  = Rails.application.config.return_trip_delay_mins
  DEFAULT_TRIP_TIME_AHEAD_MINS    = Rails.application.config.trip_time_ahead_mins
    
  # Modes for creating/updating new trips
  MODE_NEW = "1"        # Its a new trip from scratch
  MODE_EDIT = "2"       # Editing an existing trip that is in the future
  MODE_REPEAT = "3"     # Repeating an existing trip that is in the past
      
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
      @trips = @traveler.trips.scheduled_between(duration.first, duration.last)
    else
      # the filter is a trip purpose
      # Okay to leave as UTC since we're just sorting by it?
      @trips = @traveler.trips.where('trip_purpose_id = ?', @time_filter_type).sort_by {|x| x.trip_datetime }.reverse
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trips }
    end
    
  end
     
  # GET /trips/1
  # GET /trips/1.json
  def show
    @show_hidden = params[:show_hidden]

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end
  end

  def show_printer_friendly
    @show_hidden = params[:show_hidden]
    @print = params[:print]

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end
  end

  def email
    Rails.logger.info "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    if user_signed_in?
      params[:email][:send_email_to].each do |email|
        unless email == ""
          email_addresses << email
        end
      end
    end

    Rails.logger.info email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    if from_email == ""
    from_email = Oneclick::Application.config.name
    end
    subject = Oneclick::Application.config.name + ' Trip Itinerary'
    UserMailer.user_trip_email(email_addresses, @trip, subject, from_email,
      params[:email][:email_comments]).deliver
    respond_to do |format|
      format.html { redirect_to user_trip_url(@trip.creator, @trip), :notice => "An email was sent to #{email_addresses.to_sentence}."  }
      format.json { render json: @trip }
    end
  end

  def email_provider
    Rails.logger.info "Begin email"
    emails = []
    @trip = Trip.find(params[:id].to_i)
    from_email = user_signed_in? ? current_user.email : params[:email][:from]

    #IF this is a guest, save their email address
    unless user_signed_in?
      @trip.user.email = from_email
      @trip.user.save
    end

    #If the outbound trip has selected an itinerary with a service, mail it. Otherwise mail the return itinerary
    if @trip.outbound_part.selected_itinerary.service
      provider = @trip.outbound_part.selected_itinerary.service.provider
    else
      provider = @trip.return_part.selected_itinerary.service.provider
    end

    comments = params[:email][:comments]
    if params[:email][:copy_self] == '1'
      emails << from_email
    end
    subject = Oneclick::Application.config.name + ' Trip Request'
    UserMailer.provider_trip_email(emails, @trip, subject, from_email, comments).deliver
    respond_to do |format|
      format.html { redirect_to user_trip_url(@trip.creator, @trip), :notice => "An email was sent to #{provider.name}."  }
      format.json { render json: @trip }
    end
  end

  def email_itinerary
    @itinerary = Itinerary.find(params[:itinerary].to_i)

    Rails.logger.info "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    Rails.logger.info email_addresses.inspect
    email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    Rails.logger.info email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    subject = Oneclick::Application.config.name + ' Trip Itinerary'
    UserMailer.user_itinerary_email(email_addresses, @trip, @itinerary, subject, from_email,
      params[:email][:email_comments]).deliver
    respond_to do |format|
      format.html { redirect_to user_trip_url(@trip.creator, @trip), :notice => "An email was sent to #{email_addresses.join(', ')}."  }
      format.json { render json: @trip }
    end
  end

  def email_feedback
    Rails.logger.info "Begin email"
    @trip = Trip.find(params[:id])
    email_address = @trip.user.email
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    UserMailer.feedback_email(email_address, @trip, from_email).deliver
    respond_to do |format|
      format.html { redirect_to admin_trips_path, :notice => "An email was sent to #{email_address}."  }
      format.json { render json: @trip }
    end
  end
      
  def email_itinerary2_values
    # @itinerary = Itinerary.find(params[:itinerary].to_i)

    # Rails.logger.info "Begin email"
    # email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    # Rails.logger.info email_addresses.inspect
    # email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    # email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    # Rails.logger.info email_addresses.inspect
    # from_email = user_signed_in? ? current_user.email : params[:email][:from]
    # UserMailer.user_itinerary_email(email_addresses, @trip, @itinerary, "ARC OneClick Trip Itinerary", from_email).deliver
    services = @trip.trip_parts.collect {|tp| tp.itineraries.valid.selected.collect{|i| i.service.name}}
    providers = @trip.trip_parts.collect {|tp| tp.itineraries.valid.selected.collect{|i| i.provider.name}}
    respond_to do |format|
      # format.html { redirect_to user_trip_url(@trip.creator, @trip), :notice => "An email was sent to #{email_addresses.join(', ')}."  }
      format.json { render json: @trip }
    end
  end

  def email2
  end
      
  # GET /trips/1
  # GET /trips/1.json
  def details
    respond_to do |format|
      format.html # details.html.erb
      format.json { render json: @trip }
    end
  end
      
  # User wants to repeat a trip  
  def repeat
    # make sure we can find the trip we are supposed to be repeating and that it belongs to us. 
    if @trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_REPEAT

    # Set the travel time/date to the default
    travel_date = default_trip_time
    
    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    
    if @trip_proxy.is_round_trip == "1"
      return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
      @trip_proxy.return_trip_time = return_trip_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    end
        
    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      format.html { render :action => 'edit'}
    end
  end

  # User wants to edit a trip in the future  
  def edit
    # make sure we can find the trip we are supposed to be updating and that it belongs to us. 
    if @trip.nil? 
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_EDIT
    # Set the trip proxy Id to the PK of the trip so we can update it
    @trip_proxy.id = @trip.id

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
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
    
    redirect_to root_path, :alert => t(:assisting_turned_off)

  end

  # The user has elected to assist another user.
  def set_traveler

    # set or update the traveler session key with the id of the traveler
    set_traveler_id(params[:trip_proxy][:traveler])
    
    # set the @traveler variable
    get_traveler
    
    # show the new form
    redirect_to new_user_trip_path(@traveler)
    
  end
    
  # called when the user wants to delete a trip
  def destroy
    # make sure we can find the trip we are supposed to be removing and that it belongs to us. 
    if @trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_url, :flash => { :alert => t(:error_404) })
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
      format.html { redirect_to(user_trips_path(@traveler), :flash => { :notice => message}) }
      format.json { head :no_content }
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
  
    # Set the trip purpose to its default
    @trip_proxy.trip_purpose_id = TripPurpose.all.first.id
    
    # default to a round trip. The default return trip time is set the the default trip time plus
    # a configurable interval
    return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    @trip_proxy.is_round_trip = "1"
    @trip_proxy.return_trip_time = return_trip_time.strftime(TRIP_TIME_FORMAT_STRING)

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

  # updates a trip
  def update
    # make sure we can find the trip we are supposed to be updating and that it belongs to us. 
    if @trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    # make sure that the trip can be modified 
    unless @trip.can_modify
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return            
    end
    
    # Get the updated trip proxy from the form params
    @trip_proxy = create_trip_proxy_from_form_params
    # save the id of the trip we are updating
    @trip_proxy.id = @trip.id

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)
    
    # see if we can continue saving this trip                
    if @trip_proxy.errors.empty?

      # create a trip from the trip proxy. We need to do this first before any
      # trip places are removed from the database
      updated_trip = create_trip(@trip_proxy)

      # remove any child objects in the old trip
      @trip.clean      
      @trip.save
      
      # Start updating the trip from the form-based one

      # update the associations      
      @trip.trip_purpose = updated_trip.trip_purpose
      @trip.creator = @traveler      
      updated_trip.trip_places.each do |tp|
        tp.trip = @trip
        @trip.trip_places << tp
      end
      updated_trip.trip_parts.each do |pt|
        pt.trip = @trip
        @trip.trip_parts << pt
      end
    end

    respond_to do |format|
      if updated_trip # only created if the form validated and there are no geocoding errors
        if @trip.save
          @trip.reload

          if @traveler.user_profile.has_characteristics? and user_signed_in?
            @trip.create_itineraries
            @path = user_trip_path(@traveler, @trip)
          else
            session[:current_trip_id] = @trip.id
            @path = new_user_characteristic_path(@traveler, inline: 1)
          end
          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
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
       
    Rails.logger.info "TripsController#create"
    Rails.logger.info "@trip_proxy #{@trip_proxy.ai}"
    Rails.logger.info "valid? #{@trip_proxy.valid?}"
    if @trip_proxy.valid?
      @trip = create_trip(@trip_proxy)
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      if @trip
        if @trip.save
          @trip.cache_trip_places_georaw
          @trip.reload
          # @trip.restore_trip_places_georaw
          if @traveler.user_profile.has_characteristics? and user_signed_in?
            @trip.create_itineraries
            @path = user_trip_path(@traveler, @trip)
          else
            session[:current_trip_id] = @trip.id
            @path = new_user_characteristic_path(@traveler, inline: 1)
          end
          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          format.html { render action: "new" }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "new", flash[:alert] => t(:correct_errors_to_create_a_trip) }
      end
    end
  end

  def skip
    @trip = Trip.find(session[:current_trip_id])
    @trip.trip_parts.each do |tp|
      tp.create_itineraries
    end
    @path = user_trip_path(@traveler, @trip)
    session[:current_trip_id] = nil

    respond_to do |format|
      format.html { redirect_to @path }
    end
  end

  # Called when the user displays an itinerary details in the modal popup
  def itinerary
    @itinerary = @trip.itineraries.valid.find(params[:itin])
    @legs = @itinerary.get_legs
    if @itinerary.is_mappable      
      @markers = create_itinerary_markers(@itinerary).to_json
      @polylines = create_itinerary_polylines(@legs).to_json
    end
    
    #Rails.logger.debug @itinerary.inspect
    #Rails.logger.debug @markers.inspect    
    #Rails.logger.debug @polylines.inspect

    @itinerary = ItineraryDecorator.decorate(@itinerary)
    respond_to do |format|
      format.js 
    end
    
  end

  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide
    itinerary = @trip.itineraries.valid.find(params[:itinerary])
    if itinerary.nil?
      render text: t(:unable_to_remove_itinerary), status: 500
      return
    end

    itinerary.hidden = true
    
    respond_to do |format|
      if itinerary.save
        @trip.reload
        # format.js # hide.js.haml
        # TOOD For now, don't do ajax
        format.html { redirect_to user_trip_path(@traveler, @trip) }
      else
        # TODO for now, no ajax
        # render text: t(:unable_to_remove_itinerary), status: 500
        format.html { redirect_to(user_trip_path(@traveler, @trip), :flash => { error: t(:unable_to_remove_itinerary)}) } 
      end
    end
  end

  # Unhides all the hidden itineraries for a trip
  def unhide_all
    @trip.itineraries.valid.hidden.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_trip_path(@traveler, @trip)   
  end

  def select
    # hides all other itineraries for this trip part
    Rails.logger.info params.inspect
    itinerary = @trip.itineraries.valid.find(params[:itin])
    itinerary.hide_others
    respond_to do |format|
      format.html { redirect_to(user_trip_path(@traveler, @trip)) } 
      format.json { head :no_content }
    end
  end

  def comments
    @trip = Trip.find(params[:id].to_i)
    @trip.user_comments = params['trip']['user_comments']
    @trip.save

    respond_to do |format|
      format.html { redirect_to(user_trips_path(@traveler), :flash => { :notice => t(:comments_sent)}) }
      format.json { head :no_content }
    end
  end

  def admin_comments
    @trip = Trip.find(params[:id].to_i)
    @trip.user_comments = params['trip']['user_comments']
    @trip.save
    respond_to do |format|
      format.html { redirect_to(admin_trips_path, :flash => { :notice => t(:comments_updated)}) }
      format.json { head :no_content }
    end
  end

protected
  
  # Set the default travel time/date to x mins from now
  def default_trip_time
    return Time.now.in_time_zone.next_interval(DEFAULT_TRIP_TIME_AHEAD_MINS.minutes)    
  end
  
  # Safely set the @trip variable taking into account trip ownership
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    if @traveler.has_role? :admin
      @trip = Trip.find(params[:id])
    else
      begin
        @trip = @traveler.trips.find(params[:id])
      rescue => ex
        Rails.logger.debug ex.message
        @trip = nil
      end
    end
  end

  # Create an array of map markers suitable for the Leaflet plugin. If the trip proxy is from an existing trip we will
  # have start and stop markers
  def create_markers(trip_proxy)
    markers = []
    if trip_proxy.from_place_selected
      place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected.to_i, true)
    else
      place = {:name => trip_proxy.from_place, :lat => trip_proxy.from_lat, :lon => trip_proxy.from_lon, :formatted_address => trip_proxy.from_raw_address}
    end
    markers << get_addr_marker(place, 'start', 'startIcon')
    
    if trip_proxy.to_place_selected
      place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected.to_i, false)
    else
      place = {:name => trip_proxy.to_place, :lat => trip_proxy.to_lat, :lon => trip_proxy.to_lon, :formatted_address => trip_proxy.to_raw_address}
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
    
    Rails.logger.debug trip_proxy.inspect
    
    return trip_proxy
        
  end
  
  # creates a trip_proxy object from a trip. Note that this does not set the
  # trip id into the proxy as only edit functions need this.
  def create_trip_proxy(trip)

    # get the trip parts for this trip
    trip_part = trip.trip_parts.first
    
    # initialize a trip proxy from this trip
    trip_proxy = TripProxy.new
    trip_proxy.traveler = @traveler
    trip_proxy.trip_purpose_id = trip.trip_purpose.id

    trip_proxy.arrive_depart = trip_part.is_depart
    trip_datetime = trip_part.trip_time
    trip_proxy.trip_date = trip_part.scheduled_date.strftime(TRIP_DATE_FORMAT_STRING)
    trip_proxy.trip_time = trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    Rails.logger.info "create_trip_proxy"
    Rails.logger.info "trip_part.scheduled_date #{trip_part.scheduled_date}"
    Rails.logger.info "trip_part.scheduled_time #{trip_part.scheduled_time}"
    Rails.logger.info "trip_proxy.trip_date #{trip_proxy.trip_date}"
    Rails.logger.info "trip_proxy.trip_time #{trip_proxy.trip_time}"

    # Check for return trips
    if trip.trip_parts.count > 1
      last_trip_part = trip.trip_parts.last
      trip_proxy.is_round_trip = last_trip_part.is_return_trip ? "1" : "0"
      trip_proxy.return_trip_time = last_trip_part.scheduled_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    end
    
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
      trip_proxy.from_place_selected_type = CACHED_ADDRESS_TYPE      
      trip_proxy.from_place_selected = trip.trip_places.first.id      
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
      trip_proxy.to_place_selected_type = CACHED_ADDRESS_TYPE      
      trip_proxy.to_place_selected = trip.trip_places.last.id      
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
      from_place.raw_address = place[:formatted_address]
      from_place.address1 = place[:street_address]
      from_place.city = place[:city]
      from_place.state = place[:state]
      from_place.zip = place[:zip]
      from_place.county = place[:county]
      from_place.lat = place[:lat]
      from_place.lon = place[:lon]
      from_place.raw = place[:raw]
    end

    #If from_is_home, set the from place as home.
    unless trip_proxy.from_is_home.to_i == 0
      unless place[:place_id]
        new_place = Place.new
        new_place.user = @traveler
        new_place.creator = current_user
        new_place.raw_address = from_place.raw_address
        new_place.name = 'My Home'
        new_place.address1 = from_place.address1
        new_place.address2 = from_place.address2
        new_place.city = from_place.city
        new_place.state = from_place.state
        new_place.zip = from_place.zip
        new_place.county = from_place.county
        new_place.lat = from_place.lat
        new_place.lon = from_place.lon
        new_place.active = true
        from_place.place = new_place

        @traveler.clear_home
        new_place.home = true
        new_place.save
      else

        @traveler.clear_home
        from_place.place.home = true
        from_place.place.save
      end
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
      to_place.raw_address = place[:formatted_address]
      to_place.address1 = place[:street_address]
      to_place.city = place[:city]
      to_place.state = place[:state]
      to_place.zip = place[:zip]
      to_place.county = place[:county]
      to_place.lat = place[:lat]
      to_place.lon = place[:lon]
      to_place.raw = place[:raw]
    end


    #If to_is_home, set the to place as home.
    unless trip_proxy.to_is_home.to_i == 0
      unless place[:place_id]
        new_place = Place.new
        new_place.user = @traveler
        new_place.creator = current_user
        new_place.raw_address = to_place.raw_address
        new_place.name = 'My Home'
        new_place.address1 = to_place.address1
        new_place.address2 = to_place.address2
        new_place.city = to_place.city
        new_place.state = to_place.state
        new_place.zip = to_place.zip
        new_place.county = to_place.county
        new_place.lat = to_place.lat
        new_place.lon = to_place.lon
        new_place.active = true
        to_place.place = new_place

        @traveler.clear_home
        new_place.home = true
        new_place.save
      else

        @traveler.clear_home
        to_place.place.home = true
        to_place.place.save
      end
    end


    # add the places to the trip
    trip.trip_places << from_place
    trip.trip_places << to_place

    # Create the trip parts. For now we only have at most two but there could be more
    # in later versions
    
    # set the sequence counter for when we have multiple trip parts
    sequence = 0

    trip_date = Date.strptime(trip_proxy.trip_date, '%m/%d/%Y')
    
    # Create the outbound trip part
    trip_part = TripPart.new
    trip_part.trip = trip
    trip_part.sequence = sequence
    trip_part.is_depart = trip_proxy.arrive_depart == t(:departing_at) ? true : false
    trip_part.scheduled_date = trip_date
    trip_part.scheduled_time = Time.zone.parse(trip_proxy.trip_time)
    Rails.logger.info "create_trip"
    Rails.logger.info "trip_date #{trip_date}"
    Rails.logger.info "trip_part.scheduled_date #{trip_part.scheduled_date}"
    Rails.logger.info "trip_proxy.trip_time #{trip_proxy.trip_time}"
    Rails.logger.info "trip_part.scheduled_time #{trip_part.scheduled_time}"
    trip_part.from_trip_place = from_place
    trip_part.to_trip_place = to_place
    
    trip.trip_parts << trip_part
    
    # create the round trip if needed
    if trip_proxy.is_round_trip == "1"
      sequence += 1
      trip_part = TripPart.new
      trip_part.trip = trip
      trip_part.sequence = sequence
      # the return trip is always a depart at
      trip_part.is_depart = true
      # the return trip time is the arrival time plus
      trip_part.is_return_trip = true
      trip_part.scheduled_date = trip_date
      trip_part.scheduled_time = Time.zone.parse(trip_proxy.return_trip_time)
      trip_part.from_trip_place = to_place
      trip_part.to_trip_place = from_place      

      trip.trip_parts << trip_part
    end
   
    return trip
  end
  
  # Get the selected place for this trip-end based on the type of place
  # selected and the data for that place
  def get_preselected_place(place_type, place_id, is_from = false)
    
    if place_type == POI_TYPE
      # the user selected a POI using the type-ahead function
      poi = Poi.find(place_id)
      return {
        :poi_id => poi.id,
        :name => poi.name, 
        :formatted_address => poi.address, 
        :lat => poi.location.first, 
        :lon => poi.location.last 
        } 
    elsif place_type == CACHED_ADDRESS_TYPE
      # the user selected an address from the trip-places table using the type-ahead function
      trip_place = @traveler.trip_places.find(place_id)
      return {
        :name => trip_place.raw_address, 
        :lat => trip_place.lat, 
        :lon => trip_place.lon, 
        :formatted_address => trip_place.raw, 
        :street_address => trip_place.address1, 
        :city => trip_place.city, 
        :state => trip_place.state, 
        :zip => trip_place.zip, 
        :county => trip_place.county,
        :raw => trip_place.raw
        }
    elsif place_type == PLACES_TYPE
      # the user selected a place using the places drop-down
      place = @traveler.places.find(place_id)
      return {
        :place_id => place.id, 
        :name => place.name, 
        :formatted_address => place.address, 
        :lat => place.location.first, 
        :lon => place.location.last 
        }
    elsif place_type == RAW_ADDRESS_TYPE
      # the user entered a raw address and possibly selected an alternate from the list of possible
      # addresses
      if is_from
        #puts place_id
        #puts get_cached_addresses(CACHED_FROM_ADDRESSES_KEY).ai
        place = get_cached_addresses(CACHED_FROM_ADDRESSES_KEY)[place_id]
      else
        place = get_cached_addresses(CACHED_TO_ADDRESSES_KEY)[place_id]
      end
      Rails.logger.debug "in get_preselected_place"
      Rails.logger.debug "#{is_from} #{place.ai}"
      return {
        :name => place[:name], 
        :lat => place[:lat], 
        :lon => place[:lon], 
        :formatted_address => place[:formatted_address], 
        :street_address => place[:street_address], 
        :city => place[:city], 
        :state => place[:state], 
        :zip => place[:zip], 
        :county => place[:county],
        :raw => place[:raw]
        }
    else
      return {}
    end
  end
end
