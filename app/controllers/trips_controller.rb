class TripsController < ApplicationController
  
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:email, :show, :details]

  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'
  
  def email
    if user_signed_in?
      UserMailer.user_trip_email(current_user, @trip, "Arc OneClick Trip Itinerary").deliver
    else
      UserMailer.user_trip_email(current_user, @trip, "Arc OneClick Trip Itinerary").deliver
    end  
    respond_to do |format|
      format.html { redirect_to(@trip, :notice => "An email was sent to #{current_user.email}. Please check your inbox." ) }
      format.json { render json: @trip }
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
    
    if user_signed_in?
      # limit trips to trips owned by the user unless an admin
      if current_user.has_role? :admin
        @trips = Trip.created_between(duration.first, duration.last)
      else
        @trips = current_user.trips.created_between(duration.first, duration.last)
      end
    else
      # TODO Workaround for now; it has to be a trip not owned by a user (but
      # this is astill a security hole)
      @trips = Trip.anonymous.created_between(duration.first, duration.last)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trips }
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

  # GET /trips/1
  # GET /trips/1.json
  def details
    
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
    if itinerary.trip.owner != current_user
      render text: 'Unable to remove itinerary.', status: 500
      return
    end

    respond_to do |format|
      if itinerary
        @trip = itinerary.trip
        itinerary.hide
        format.js # hide.js.haml
      else
        render text: 'Unable to remove itinerary.', status: 500
      end
    end
  end

  # GET /trips/new
  # GET /trips/new.json
  def new
    @trip = Trip.new
    # TODO User might be different if we are an agent
    @trip.owner = current_user || anonymous_user
    @trip.build_from_place(sequence: 0)
    @trip.build_to_place(sequence: 1)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip }
    end
  end

  # POST /trips
  # POST /trips.json
  def create
    params[:trip][:owner] = current_user || anonymous_user
    @trip = Trip.new(params[:trip])
    # @trip.owner = current_user || anonymous_user

    respond_to do |format|
      if @trip.save
        @trip.reload
        @trip.create_itineraries
        unless @trip.has_valid_itineraries?
          message = t(:trip_created_no_valid_options)
          details = @trip.itineraries.collect do |i|
            "<li>%s (%s)</li>" % [i.message, i.status]
          end
          message = message + '<ol>' + details.join + '</ol>'
          flash[:error] = message.html_safe
        end
        format.html { redirect_to @trip }
        format.json { render json: @trip, status: :created, location: @trip }
      else
        Rails.logger.info @trip.ai
        Rails.logger.info @trip.places.ai
        Rails.logger.info @trip.from_place.ai
        Rails.logger.info @trip.to_place.ai
        format.html { render action: "new" }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

protected

  def get_trip
    if user_signed_in?
      # limit trips to trips owned by the user unless an admin
      if current_user.has_role? :admin
        @trip = Trip.find(params[:id])
      else
        @trip = current_user.trips.find(params[:id])
      end
    else
      # TODO Workaround for now; it has to be a trip not owned by a user (but
      # this is astill a security hole)
      @trip = Trip.find_by_id_and_user_id(params[:id], nil)
    end    
  end
end
