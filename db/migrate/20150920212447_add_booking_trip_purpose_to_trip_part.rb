class AddBookingTripPurposeToTripPart < ActiveRecord::Migration
  def change
    add_column :trip_parts, :booking_trip_purpose_id, :integer
    add_column :trip_parts, :booking_trip_purpose_desc, :string
  end
end
