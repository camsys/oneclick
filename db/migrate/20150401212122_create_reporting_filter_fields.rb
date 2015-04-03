class CreateReportingFilterFields < ActiveRecord::Migration
  def change
    create_table :reporting_filter_fields do |t|
      t.references :reporting_report, index: true, foreign_key: true, null: false
      t.references :reporting_filter_group, index: true, foreign_key: true, null: false
      t.references :reporting_filter_type, index: true, foreign_key: true, null: false
      t.references :reporting_lookup_table, index: true, foreign_key: true
      t.string :name, null: false
      t.string :title

      t.timestamps null: false
    end
  end
end
