class DropReports < ActiveRecord::Migration
  def change
    drop_table :reporting_output_fields
  end
end
