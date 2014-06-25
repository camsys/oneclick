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

    if @report
                    
      # set up the report view
      @report_view = @report.view_name
      # get the class instance and generate the data
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(current_user, @generated_report)
      @columns = report_instance.get_columns
      @url_for_csv = url_for only_path: true, format: :csv, params: params
      
      respond_to do |format|
        format.html
        format.csv { render text: get_csv(@columns, @data) }
      end
    end

  end

  def get_csv(columns, data)
    CSV.generate do |csv|
      csv << I18n.t(columns)
      data.each do |row|
        csv << columns.map {|col| row.send(col) }
      end
    end
  end
  
end
