class AddValueTypeToReportingFilterFields < ActiveRecord::Migration
  def change
    unless column_exists? :reporting_filter_fields, :value_type
      add_column :reporting_filter_fields, :value_type, :string
    end
  end
end
