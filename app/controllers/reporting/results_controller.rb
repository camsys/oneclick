module Reporting
  class ResultsController < ApplicationController
    authorize_resource :class => false  

    def index
      q_param = params[:q]
      page = params[:page]
      @per_page = params[:per_page] || Kaminari.config.default_per_page

      @report = ReportingReport.find params[:report_id]
      @q = @report.data_model.ransack q_param
      @params = {q: q_param}

      begin
        # total_results is for exporting
        total_results = @q.result(:district => true)
        total_results = total_results.order(:id) if !@report.data_model.columns_hash.keys.index("id").nil?
        # @results is for html display; only render current page
        @results = total_results.page(page).per(@per_page)

        # this is used to test if any sql exception is triggered in querying
        # commen errors: table not found
        first_result = @results.first 

        # list all output fields
        # if output_fields is empty, then export all columns in this table
        @fields = @report.reporting_output_fields.blank? ?
          @report.data_model.column_names.map{
            |x| {
              name: x 
            }
          } : @report.reporting_output_fields

      rescue => e
        # error message handling

        total_results = []
        @results = []
        @fields = []
      end

      respond_to do |format|
        format.html
        format.csv { send_data total_results.to_csv }
      end

    end
  end
end
