class AddReportingReportRefToReportingFilterGroups < ActiveRecord::Migration
  def up
    add_reference :reporting_filter_groups, :reporting_report, index: true
  end

  def down
    remove_reference :reporting_filter_groups, :reporting_report, index: true
  end
end
