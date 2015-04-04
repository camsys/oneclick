##
# Controller for customized reports
# Generic reports, please refer to Reporting::ReportsController
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
  ORDER_PARAMS_KEY = 'order'
  COLUMNS_PARAMS_KEY = 'columns'
  START_PARAMS_KEY = 'start'
  LENGTH_PARAMS_KEY = 'length'
  
  def show
    @report = Report.find(params[:id])
    
    @reports = Reporting::ReportingReport.all_report_infos # get all report infos (id, name) both generic and customized reports
    @generated_report = GeneratedReport.new({})
    @generated_report.date_range = session[DATE_OPTION_SESSION_KEY] || DateOption::DEFAULT
    @min_trip_date = Trip.minimum(:scheduled_time)

    set_user_based_constraints
  end

  # renders a report page. Actual details depends on the id parameter passed
  # from the view
  def results
    @report = Report.find(params[:report_id])
    # params[:generated_report] can be nil if switching locales, redirect
    if params[:generated_report].nil?
      redirect_to admin_reports_path
      return
    end
    
    @generated_report = GeneratedReport.new(params[:generated_report])

    # Store filter settings in session for ajax calls.
    @generated_report.date_range ||= session[DATE_OPTION_SESSION_KEY] || DateOption::DEFAULT
    @min_trip_date = Trip.minimum(:scheduled_time)
    session[DATE_OPTION_SESSION_KEY] = @generated_report.date_range
    session[DATE_OPTION_FROM_KEY] = @generated_report.from_date
    session[DATE_OPTION_TO_KEY] = @generated_report.to_date
    session[AGENCY_OPTION_KEY] = @generated_report.agency_id
    session[AGENT_OPTION_KEY] = @generated_report.agent_id
    session[PROVIDER_OPTION_KEY] = @generated_report.provider_id
    
    if @report

      params[:order] = session[ORDER_PARAMS_KEY]
      params[:columns] = session[COLUMNS_PARAMS_KEY]
      params[:start] = session[START_PARAMS_KEY]
      params[:length] = session[LENGTH_PARAMS_KEY]
      
      # set up the report view
      @report_view = @report.view_name
      # get the class instance and generate the data
      if @report.id != Report.system_usage_report_id
        @report_instance = @report.class_name.constantize.new(view_context)
        @data = @report_instance.get_data(current_user, @generated_report) unless @report_instance.paged
      else
        @report_instance = @report.class_name.constantize.new(
          Chronic.parse(params[:generated_report][:standard_usage_report_effective_date]),
          params[:generated_report][:standard_usage_report_date_option])
      end

      @columns = @report_instance.get_columns
      @url_for_csv = url_for only_path: true, format: :csv, params: params

      set_user_based_constraints

      respond_to do |format|
        format.html
        format.csv do
          send_data get_csv,
                filename: "#{I18n.t(@report.class_name).parameterize.underscore}.csv", type: :text
        end
      end
    end

  end

  def get_csv
    is_standard_system_report = (@report.id == Report.system_usage_report_id)
    if is_standard_system_report
      data = @report_instance.get_data
    else
      data = @report_instance.get_data(current_user, @generated_report)
    end

    # Excel is stupid if the first two characters of a csv file are "ID". Necessary to
    # escape it. https://support.microsoft.com/kb/215591/EN-US
    CSV.generate do |csv|
      xlated_columns = if is_standard_system_report
        @report_instance.get_localized_columns
      else
        @columns.map {|col| I18n.t(col)}
      end

      if xlated_columns[0].start_with? "ID"
        headers = Array.new(xlated_columns)
        headers[0] = "'" + headers[0]
      else
        headers = xlated_columns
      end

      csv << headers

      if is_standard_system_report
        data.each do |row|
          csv << row
        end
      else
        data.each do |row|
          row = row.decorate
          csv << @columns.map {|col| row.send(col) }
        end
      end
    end

  end

  def trips_datatable
    respond_to do |format|
      format.json do
        date_option = DateOption.find(session[DATE_OPTION_SESSION_KEY])
        from_date = session[DATE_OPTION_FROM_KEY]
        to_date = session[DATE_OPTION_TO_KEY]

        session[ORDER_PARAMS_KEY] = params[:order]
        session[START_PARAMS_KEY] = params[:start]
        session[LENGTH_PARAMS_KEY] = params[:length]

        table = TripsDatatable.new(view_context,
                                   { dates: date_option,
                                     from_date: from_date,
                                     to_date: to_date,
                                     agency_id: session[AGENCY_OPTION_KEY],
                                     agent_id: session[AGENT_OPTION_KEY],
                                     provider_id: session[PROVIDER_OPTION_KEY],
                                   })
        # Sessions are currently stored in a cookie with a 4KB limit.
        # Rather than saving all of params[:columns] and blowing that limit
        # just save the searchable_columns.
        cols = {}
        table.searchable_columns.each_with_index do |col, index|
          cols["#{index}"] = params[:columns]["#{index}"]
        end
        session[COLUMNS_PARAMS_KEY] = cols
        
        render json: table
      end
    end
  end

  def set_user_based_constraints
    @agency = :any
    @agency_all = true
    @agency_id = false
    @provider_all = true
    @provider_id = false

    return if current_user.has_role? :system_administrator
    
    Agency.with_role(:agency_administrator, current_user).each do |a|
      @agency = a
      @agency_id = a.id
      @agency_all = false
      @provider_id = -1
    end
    
    Provider.with_role(:provider_staff, current_user).each do |p|
      @agency = nil if @agency == :any
      @agency_id = -1 unless @agency_id
      @provider_all = false
      @provider_id = p.id
    end
  end
  
end
