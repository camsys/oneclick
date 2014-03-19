class Admin::TripsController < Admin::BaseController

  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  
  def index

    puts @trips.ai

    # Filtering logic. See ApplicationHelper.trip_filters
    if params[:time_filter_type]
      @time_filter_type = params[:time_filter_type]
    else
      @time_filter_type = session[TIME_FILTER_TYPE_SESSION_KEY]
    end
    if @time_filter_type.nil?
      @time_filter_type = "100"
    end

    session[TIME_FILTER_TYPE_SESSION_KEY] = @time_filter_type

    if params[:provider_id]
      @trips = Trip.by_provider(params[:provider_id])
    elsif params[:agency_id]
      @trips = Trip.by_agency(params[:agency_id])
    else
      @trips = Trip.all
    end

    # If the filter is at least 100 is must be a time filter, otherwise it will be a TripPurpose
    if @time_filter_type.to_i >= 100
      # TODO Time filtering is pretty bizarre, let's skip it for now
      # actual_filter = @time_filter_type.to_i - 100
      # duration = TimeFilterHelper.time_filter_as_duration(actual_filter)
      # # @trips = @trips.scheduled_between(duration.first, duration.last)
      # # TODO This doesn't take into account time, but that's probably okay
      # puts @trips.where(scheduled_date: duration).to_sql
      # @trips = @trips.where(scheduled_date: duration)
    else
      @trips = @trips.where('trip_purpose_id = ?', @time_filter_type).sort_by {|x| x.trip_datetime }.reverse
    end

    respond_to do |format|
      format.html
      format.json { render json: @trips }
    end

  end

end
