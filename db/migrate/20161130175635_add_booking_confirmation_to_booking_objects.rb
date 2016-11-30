class AddBookingConfirmationToBookingObjects < ActiveRecord::Migration
  def up
    # Add booking_confirmation_number column to each booking object table
    add_column :ecolane_bookings, :confirmation_number, :string
    add_column :trapeze_bookings, :confirmation_number, :string
    add_column :ridepilot_bookings, :confirmation_number, :string

    # Copy over data from associated itineraries
    EcolaneBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation) if booking.itinerary
    end

    TrapezeBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation) if booking.itinerary
    end

    RidepilotBooking.all.each do |booking|
      booking.update_attributes(confirmation_number: booking.itinerary.booking_confirmation) if booking.itinerary
    end
  end

  def down
    # Copy over data to associated itineraries
    EcolaneBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number) if booking.itinerary
    end

    TrapezeBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number) if booking.itinerary
    end

    RidepilotBooking.all.each do |booking|
      booking.itinerary.update_attributes(booking_confirmation: booking.confirmation_number) if booking.itinerary
    end

    # Remove booking_confirmation_number column from each booking object table
    remove_column :ecolane_bookings, :confirmation_number, :string
    remove_column :trapeze_bookings, :confirmation_number, :string
    remove_column :ridepilot_bookings, :confirmation_number, :string
  end
end
