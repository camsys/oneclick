class Admin::ReportsController < Admin::BaseController
  
  # load the cancan authorizations
  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  
  def index
    @reports = Report.all
    @generated_report = GeneratedReport.new({})
  end

  # renders a report page. Actual details depends on the id parameter passed
  # from the view
  def show

    # params[:generated_report] can be nil if switching locales, redirect
    if params[:generated_report].nil?
      redirect_to admin_reports_path
      return
    end
    
    report_params = params[:generated_report]
    @generated_report = GeneratedReport.new(report_params)
    # @generated_report.report_name = report_params[:report_name]
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

    # Set date_range value and store in session
    @generated_report.date_range ||= session[:date_range] || DateOption.first.id
    session[:date_range] = @generated_report.date_range

    if @report
                    
      # set up the report view
      @report_view = @report.view_name
      # get the class instance and generate the data
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(current_user, report_params)
      @columns = report_instance.get_columns
      
      respond_to do |format|
        format.html
      end
    end

  end

end
