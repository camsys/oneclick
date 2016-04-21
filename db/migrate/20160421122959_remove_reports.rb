class RemoveReports < ActiveRecord::Migration
  def change
    drop_table :reporting_filter_fields
    drop_table :reporting_filter_groups
    drop_table :reporting_filter_types
    drop_table :reporting_lookup_tables
    drop_table :reporting_reports
    drop_table :reporting_specific_filter_groups
    drop_table :reports
  end
end
