class ReportsController < ApplicationController
  
  TIME_FILTERS = [
    {:id => 0, :value => "Last 30 days", :parse_text_start => "30 days ago", :parse_text_end => "yesterday", :is_day_duration => true},
    {:id => 1, :value => "Last 7 days", :parse_text_start => "7 days ago", :parse_text_end => "yesterday", :is_day_duration => true},
    {:id => 2, :value => "Last month", :parse_text_start => "last month", :parse_text_end => "last month", :is_day_duration => false}
  ]
  
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
         @time_filter_type = session[:time_filter_type]
         params[:time_filter_type] = session[:time_filter_type]
      end
      session[:time_filter_type] = @time_filter_type
         
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
