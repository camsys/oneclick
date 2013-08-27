class ReportsController < ApplicationController
  
  # load the cancan authorizations
  load_and_authorize_resource  
  
  TIME_FILTER_TYPE_SESSION_KEY = 'reports_time_filter_type'
  
  def index
    
    @reports = Report.all
        
  end

  # renders a dashboard detail page. Actual details depends on the id parameter passed
  # from the view
  def show
    
    @report = Report.find(params[:id])
    
    if @report
      # view params needed for the subnav filters
      if params[:time_filter_type]
        @time_filter_type = params[:time_filter_type]
      else
         @time_filter_type = session[TIME_FILTER_TYPE_SESSION_KEY]
         params[:time_filter_type] = session[TIME_FILTER_TYPE_SESSION_KEY]
      end
      session[TIME_FILTER_TYPE_SESSION_KEY] = @time_filter_type
         
      # set up the report view
      @report_view = @report.view_name
      # get the class instance and generate the data
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(current_user, params)
      respond_to do |format|
        format.html
      end
    end
  end

end
