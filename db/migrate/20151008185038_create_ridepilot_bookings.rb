class CreateRidepilotBookings < ActiveRecord::Migration
  def change
    create_table :ridepilot_bookings do |t|
      t.integer :leg
      t.integer :guests
      t.integer :attendants
      t.integer :mobility_devices
      t.integer :itinerary_id
      t.string  :trip_purpose_code
      t.timestamps
    end
  end
end
