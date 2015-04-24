class Admin::TripPartsController < Admin::BaseController
  check_authorization
  load_and_authorize_resource

  def index
    authorize! :access, :admin_trip_parts

    # trip_view
    q_param = params[:q]
    page = params[:page]
    @per_page = params[:per_page] || Kaminari.config.default_per_page

    @q = TripPartView.ransack q_param
    @q.sorts = "id asc" if @q.sorts.empty?
    @params = {q: q_param}

    total_parts = @q.result(:district => true)

    # filter data based on accessibility
    if params[:provider_id]
      total_parts = total_parts.by_provider(params[:provider_id])
    end
        
    # @results is for html display; only render current page
    @trip_parts = total_parts.page(page).per(@per_page)

    respond_to do |format|
      format.html
      format.json { render json: @trip_parts }
      format.csv do 
        render_csv("trip_parts.csv", total_parts, TripPartView.csv_headers, TripPartView.csv_columns)
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
