class AddBookingMigrationToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :booking_confirmation, :string
  end
end
