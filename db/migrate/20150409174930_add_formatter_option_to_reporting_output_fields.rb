class AddFormatterOptionToReportingOutputFields < ActiveRecord::Migration
  def change
    add_column :reporting_output_fields, :numeric_precision, :integer
  end
end
