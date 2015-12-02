class CreateEcolaneProfilesTable < ActiveRecord::Migration
  def change
    create_table :ecolane_profiles do |t|
      t.timestamps
      t.string :default_trip_purpose
    end
  end
end
