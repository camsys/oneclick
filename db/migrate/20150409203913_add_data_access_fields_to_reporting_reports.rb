class AddDataAccessFieldsToReportingReports < ActiveRecord::Migration
  def change
    add_column :reporting_reports, :is_sys_admin, :boolean
    add_column :reporting_reports, :is_provider_admin, :boolean
    add_column :reporting_reports, :is_agency_admin, :boolean
    add_column :reporting_reports, :is_agent, :boolean
    add_column :reporting_reports, :data_access_type, :string
    add_column :reporting_reports, :data_access_field_name, :string
  end
end
