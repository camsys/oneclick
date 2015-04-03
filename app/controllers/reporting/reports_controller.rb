module Reporting
  class ReportsController < ApplicationController
    def index
      @reports = ReportingReport.order(:name)
      redirect_to reporting_report_path(@reports.first) if @reports.first
    end

    def show
      @reports = ReportingReport.order(:name)
      @report = ReportingReport.find(params[:id])

      # find out filter_groups
      @filter_groups = ReportingFilterGroup.where(id: @report.reporting_filter_fields.pluck(:reporting_filter_group_id).uniq)
    end
    
  end
end
