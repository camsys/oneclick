class CreateReportingOutputFields < ActiveRecord::Migration
  def change
    create_table :reporting_output_fields do |t|
      t.references :reporting_report, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.string :title

      t.timestamps null: false
    end
  end
end
