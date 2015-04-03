class CreateReportingLookupTables < ActiveRecord::Migration
  def change
    create_table :reporting_lookup_tables do |t|
      t.string :name, null: false
      t.string :display_field_name, null: false

      t.timestamps null: false
    end
  end
end
