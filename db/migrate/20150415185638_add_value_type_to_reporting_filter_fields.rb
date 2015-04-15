class AddValueTypeToReportingFilterFields < ActiveRecord::Migration
  def change
    add_column :reporting_filter_fields, :value_type, :string
  end
end
