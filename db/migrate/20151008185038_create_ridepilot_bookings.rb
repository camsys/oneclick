class CreateRidepilotBookings < ActiveRecord::Migration
  def change
    create_table :ridepilot_bookings do |t|
      t.integer :guests
      t.integer :attendants
      t.integer :mobility_devices
      t.integer :itinerary_id
      t.string  :trip_purpose_code
      t.string  :booking_status_code
      t.string  :booking_status_message
      t.timestamps
    end
  end
end
