class AddTripIdToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :trip_id, :integer
  end
end
