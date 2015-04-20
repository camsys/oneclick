class Admin::TripsController < Admin::BaseController
  check_authorization
  load_and_authorize_resource

  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'

  def index
    authorize! :access, :admin_trips

    # trip_view
    q_param = params[:q]
    page = params[:page]
    @per_page = params[:per_page] || Kaminari.config.default_per_page

    @q = TripView.ransack q_param
    @params = {q: q_param}

    total_trips = @q.result(:district => true)

    # filter data based on accessibility
    if params[:provider_id]
      total_trips = total_trips.by_provider(params[:provider_id])
    elsif params[:agency_id]
      total_trips = total_trips.by_agency(params[:agency_id])
    end
        
    # @results is for html display; only render current page
    @trip_views = total_trips.page(page).per(@per_page)
    array_of_ids = @trip_views.pluck("\"#{TripView.id_column}\"")
    
    @trips = Trip.where(id: array_of_ids).index_by(&:id).values_at(*array_of_ids)

    respond_to do |format|
      format.html
      format.json { render json: @trips }
    end

  end

end
