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
    @q.sorts = "#{TripView.primary_key} asc" if @q.sorts.empty?
    @params = {q: q_param}

    total_trips = @q.result(:district => true).uniq(:id)

    # filter data based on accessibility
    if params[:provider_id]
      total_trips = total_trips.by_provider(params[:provider_id])
    elsif params[:agency_id]
      total_trips = total_trips.by_agency(params[:agency_id])
    end
        
    # @results is for html display; only render current page
    @trip_views = total_trips.page(page).per(@per_page)
    array_of_ids = @trip_views.pluck("\"#{TripView.primary_key}\"")
    
    @trips = Trip.where(id: array_of_ids).index_by(&:id).values_at(*array_of_ids)

    respond_to do |format|
      format.html
      format.json { render json: @trips }
      format.csv do 
        render_csv("trips.csv", total_trips, TripView.csv_headers, TripView.csv_columns)
      end
    end

  end

  private 

  def render_csv(file_name, data, headers, fields)
    set_file_headers file_name
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines(data, headers, fields)
  end


  def set_file_headers(file_name)
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end


  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_lines(data, headers, fields)
    
    Enumerator.new do |y|
      y << headers.to_csv

      data.find_each { |row| y << fields.map { |field| row.send(field) }.to_csv }
    end

  end

end
