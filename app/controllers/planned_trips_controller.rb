class PlannedTripsController < TravelerAwareController
    
  # set the @planned_trip and @trip variables before any actions are invoked
  before_filter :get_planned_trip, :except => [:index]

  TIME_FILTER_TYPE_SESSION_KEY = 'planned_trips_time_filter_type'
  
  def email
    Rails.logger.info "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    Rails.logger.info email_addresses.inspect
    email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    Rails.logger.info email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    UserMailer.user_trip_email(email_addresses, @planned_trip, "ARC OneClick Trip Itinerary", from_email).deliver
    respond_to do |format|
      format.html { redirect_to user_planned_trip_url(current_user, @planned_trip), :notice => "An email was sent to #{email_addresses.join(', ')}."  }
      format.json { render json: @planned_trip }
    end
  end
  
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
    
    @planned_trips = @traveler.planned_trips.scheduled_between(duration.first, duration.last)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planned_trips }
    end
    
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    # See if there is the show_hidden parameter
    @show_hidden = params[:show_hidden]
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planned_trip }
    end
  end

  def itinerary
    @itinerary = @planned_trip.valid_itineraries.find(params[:itin])
    
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

    itinerary = @planned_trip.itineraries.find(params[:itinerary])
    if itinerary.nil?
      render text: 'Unable to remove itinerary.', status: 500
      return
    end

    itinerary.hidden = true
    if itinerary.save
      respond_to do |format|
        if itinerary
          format.js # hide.js.haml
        else
          render text: 'Unable to remove itinerary.', status: 500
        end
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
