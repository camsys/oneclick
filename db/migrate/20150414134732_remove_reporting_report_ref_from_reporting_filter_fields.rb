class RemoveReportingReportRefFromReportingFilterFields < ActiveRecord::Migration
  def up
    remove_reference :reporting_filter_fields, :reporting_report, index: true
  end

  def down
    add_reference :reporting_filter_fields, :reporting_report, index: true
  end
end
