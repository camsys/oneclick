class Admin::TripsController < Admin::BaseController
  
  # load the cancan authorizations
  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  
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
      @trips = Trip.scheduled_between(duration.first, duration.last)
    else
      # the filter is a trip purpose
      @trips = Trip.where('trip_purpose_id = ?', @time_filter_type).sort_by {|x| x.trip_datetime }.reverse
    end

    #todo: TEMP FIX THIS
   # @trips = Trip.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trips }
    end

  end

end
