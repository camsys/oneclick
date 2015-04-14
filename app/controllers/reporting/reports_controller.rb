module Reporting
  class ReportsController < ApplicationController
    include ReportHelper

    before_action :verify_permission

    def index
      @reports = all_report_infos
      if !@reports.blank?
        first_report = @reports.first
        @is_generic_report = first_report[:is_generic]
        if @is_generic_report
          redirect_to reporting_report_path ReportingReport.find(first_report[:id])
        else
          redirect_to admin_report_path Report.find(first_report[:id])
        end
      end
      
    end

    def show
      @reports = all_report_infos
      @report = ReportingReport.find(params[:id])

      # find out filter_groups
      @filter_groups = @report.reporting_filter_groups.order(:sort_order)
    end

    private

    def verify_permission
      authorize! :access, :admin_reports
    end
    
  end
end
