class AddDataAccessFieldsToReportingLookupTables < ActiveRecord::Migration
  def change
    add_column :reporting_lookup_tables, :id_field_name, :string, null: false, default: 'id'
    add_column :reporting_lookup_tables, :data_access_type, :name
  end
end
