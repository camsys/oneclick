class AddFormatterToReportingOutputFields < ActiveRecord::Migration
  def change
    add_column :reporting_output_fields, :formatter, :string
  end
end
