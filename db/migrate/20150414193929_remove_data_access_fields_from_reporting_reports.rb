class RemoveDataAccessFieldsFromReportingReports < ActiveRecord::Migration
  def change
    remove_column :reporting_reports, :data_access_type
    remove_column :reporting_reports, :data_access_field_name
  end
end
