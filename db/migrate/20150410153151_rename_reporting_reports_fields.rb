class RenameReportingReportsFields < ActiveRecord::Migration
  def change
    rename_column :reporting_reports, :is_provider_admin, :is_provider_staff
  end
end
