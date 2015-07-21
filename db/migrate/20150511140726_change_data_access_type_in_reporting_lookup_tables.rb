class ChangeDataAccessTypeInReportingLookupTables < ActiveRecord::Migration
  def change
    change_column :reporting_lookup_tables, :data_access_type, :string
  end
end
