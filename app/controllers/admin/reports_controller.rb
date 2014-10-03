class Admin::ReportsController < Admin::BaseController
  
  # load the cancan authorizations
  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  DATE_OPTION_SESSION_KEY = 'date_range'
  DATE_OPTION_FROM_KEY = 'from_date'
  DATE_OPTION_TO_KEY = 'to_date'
  AGENCY_OPTION_KEY = 'agency'
  AGENT_OPTION_KEY = 'agent'
  PROVIDER_OPTION_KEY = 'provider'
  
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

    # Store filter settings in session for ajax calls.
    @generated_report.date_range ||= session[DATE_OPTION_SESSION_KEY] || DateOption::DEFAULT
    session[DATE_OPTION_SESSION_KEY] = @generated_report.date_range
    session[DATE_OPTION_FROM_KEY] = @generated_report.from_date
    session[DATE_OPTION_TO_KEY] = @generated_report.to_date
    session[AGENCY_OPTION_KEY] = @generated_report.agency_id
    session[AGENT_OPTION_KEY] = @generated_report.agent_id
    session[PROVIDER_OPTION_KEY] = @generated_report.provider_id
    
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
    respond_to do |format|
      format.json do
        date_option = DateOption.find(session[DATE_OPTION_SESSION_KEY])
        from_date = session[DATE_OPTION_FROM_KEY]
        to_date = session[DATE_OPTION_TO_KEY]

        render json: TripsDatatable.new(view_context,
                                        { dates: date_option,
                                          from_date: from_date,
                                          to_date: to_date,
                                          agent_id: session[AGENT_OPTION_KEY],
                                        })
      end
    end
  end
  
end
