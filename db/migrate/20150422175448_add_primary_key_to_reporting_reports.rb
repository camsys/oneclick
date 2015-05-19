class AddPrimaryKeyToReportingReports < ActiveRecord::Migration
  def change
    unless column_exists? :reporting_reports, :primary_key
      add_column :reporting_reports, :primary_key, :string, null: false, default: 'id'
    end
  end
end
