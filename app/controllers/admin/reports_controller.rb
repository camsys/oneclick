class Admin::ReportsController < Admin::BaseController
  
  # load the cancan authorizations
  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  DATE_OPTION_SESSION_KEY = 'date_range'

  def index
    @reports = Report.all
    @generated_report = GeneratedReport.new({})
    @generated_report.date_range = session[DATE_OPTION_SESSION_KEY] || DateOption::DEFAULT
    @min_trip_date = Trip.minimum(:scheduled_time)
  end

  # renders a report page. Actual details depends on the id parameter passed
  # from the view
  def show

    # params[:generated_report] can be nil if switching locales, redirect
    if params[:generated_report].nil?
      redirect_to admin_reports_path
      return
    end
    
    @generated_report = GeneratedReport.new(params[:generated_report])
    @report = Report.find(@generated_report.report_name)

    # TODO clean up or get rid of this
    # Filtering logic. See ApplicationHelper.trip_filters
    if params[:time_filter_type]
      @time_filter_type = params[:time_filter_type]
    else
      @time_filter_type = session[TIME_FILTER_TYPE_SESSION_KEY]
    end
    # if it is still not set use the default
    if @time_filter_type.nil?
      # default is to use the first time period filter in the TimeFilterHelper class
      @time_filter_type = "0"
    end
    # store it in the session
    session[TIME_FILTER_TYPE_SESSION_KEY] = @time_filter_type
    params[:time_filter_type] = @time_filter_type

    @generated_report.date_range ||= session[DATE_OPTION_SESSION_KEY] || DateOption::DEFAULT
    session[DATE_OPTION_SESSION_KEY] = @generated_report.date_range

    if @report
                    
      # set up the report view
      @report_view = @report.view_name
      # get the class instance and generate the data
      @report_instance = @report.class_name.constantize.new(view_context)
      @data = @report_instance.get_data(current_user, @generated_report)
      @columns = @report_instance.get_columns
      @url_for_csv = url_for only_path: true, format: :csv, params: params

      respond_to do |format|
        format.html
        format.csv { send_data get_csv(@columns, @data) }
      end
    end

  end

  def get_csv(columns, data)
    # Excel is stupid if the first two characters of a csv file are "ID". Necessary to
    # escape it. https://support.microsoft.com/kb/215591/EN-US
    CSV.generate do |csv|
      xlated_columns = I18n.t(@columns)
      if xlated_columns[0].start_with? "ID"
        headers = Array.new(xlated_columns)
        headers[0] = "'" + headers[0]
      else
        headers = xlated_columns
      end

      csv << headers
      data.each do |row|
        row = row.decorate
        csv << columns.map {|col| row.send(col) }
      end
    end
  end

  def trips_datatable
    Rails.logger.info @date_option
    respond_to do |format|
      format.json do
        date_option = DateOption.find(session[DATE_OPTION_SESSION_KEY])
        render json: TripsDatatable.new(view_context, {dates: date_option})
      end
      
    end
  end
  
end
