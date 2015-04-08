module Reporting
  class ReportsController < ApplicationController
    before_action :verify_permission

    def index
      @reports = ReportingReport.all_report_infos
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
      @reports = ReportingReport.all_report_infos
      @report = ReportingReport.find(params[:id])

      # find out filter_groups
      @filter_groups = ReportingFilterGroup.where(id: @report.reporting_filter_fields.pluck(:reporting_filter_group_id).uniq)
    end

    private

    def verify_permission
      if !can?(:access, :admin_reports)
        redirect_to root_url, :flash => { :error => t(:not_authorized) }
      end
    end
    
  end
end
