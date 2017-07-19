class CreateEcolaneBookingTable < ActiveRecord::Migration
  def change
    create_table :ecolane_bookings do |t|
      t.boolean :assistant
      t.integer :children
      t.integer :companions
      t.integer :other_passengers
      t.string  :note_to_driver
      t.string  :booking_status_code
      t.string  :booking_status_message
      t.integer :itinerary_id
      t.timestamps
    end
  end
end
