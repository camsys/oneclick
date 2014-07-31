class AddTripTimeToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :scheduled_date, :date
    add_column :trips, :scheduled_time, :time
    add_index :trips, [:scheduled_date, :scheduled_time]
  end
end
