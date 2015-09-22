class CreateTrapezeBookings < ActiveRecord::Migration
  def change
    create_table :trapeze_bookings do |t|
      t.string :passenger1_type
      t.string :passenger1_space_type
      t.string :passenger2_type
      t.string :passenger2_space_type
      t.string :passenger3_type
      t.string :passenger3_space_type
      t.integer :itinerary_id
      t.timestamps
    end
  end
end