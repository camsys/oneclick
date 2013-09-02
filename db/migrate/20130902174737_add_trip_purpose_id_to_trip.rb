class AddTripPurposeIdToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :trip_purpose_id, :int
  end
end
