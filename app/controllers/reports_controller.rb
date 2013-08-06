class ReportsController < ApplicationController
  
  def index
    
    @reports = Report.all
        
  end

  # renders a dashboard detail page. Actual details depends on the id parameter passed
  # from the view
  def show
    
    # load this report and create the report instance 
    @report = Report.find(params[:id])

    if @report
      @report_view = @report.view_name
      
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(current_user, params)
      respond_to do |format|
        format.html
      end
    end
  end

end
