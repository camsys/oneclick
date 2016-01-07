class CreateEcolaneProfilesTable < ActiveRecord::Migration
  def change
    create_table :ecolane_profiles do |t|
      t.timestamps
      t.string :default_trip_purpose
      t.integer :service_id
    end
  end
end
