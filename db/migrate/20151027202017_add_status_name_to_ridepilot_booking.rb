class AddStatusNameToRidepilotBooking < ActiveRecord::Migration
  def change
    add_column :ridepilot_bookings, :booking_status_name, :string
  end
end
