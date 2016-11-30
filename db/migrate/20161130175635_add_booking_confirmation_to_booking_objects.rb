class AddBookingConfirmationToBookingObjects < ActiveRecord::Migration
  def up
    # Add booking_confirmation_number column to each booking object table
    add_column :ecolane_bookings, :confirmation_number, :integer
    add_column :trapeze_bookings, :confirmation_number, :integer
    add_column :ridepilot_bookings, :confirmation_number, :integer

    # Copy over data from associated itineraries
    EcolaneBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation)
    end

    TrapezeBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation)
    end

    RidepilotBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation)
    end
  end

  def down
    # Copy over data to associated itineraries
    EcolaneBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number)
    end

    TrapezeBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number)
    end

    RidepilotBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number)
    end

    # Remove booking_confirmation_number column from each booking object table
    remove_column :ecolane_bookings, :confirmation_number, :integer
    remove_column :trapeze_bookings, :confirmation_number, :integer
    remove_column :ridepilot_bookings, :confirmation_number, :integer
  end
end
