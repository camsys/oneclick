class Admin::TripsController < Admin::BaseController
  check_authorization
  load_and_authorize_resource

  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'

  def index
    authorize! :access, :admin_trips

    if params[:provider_id]
      @trips = Trip.by_provider(params[:provider_id])
    elsif params[:agency_id]
      @trips = Trip.by_agency(params[:agency_id])
    else
      @trips = Trip.includes(:user, :trip_places, :trip_purpose, :trip_parts)
    end

    respond_to do |format|
      format.html
      format.json { render json: @trips }
    end

  end

end
