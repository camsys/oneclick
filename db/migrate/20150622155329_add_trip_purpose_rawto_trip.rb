class AddTripPurposeRawtoTrip < ActiveRecord::Migration
  def change
    add_column :trips, :trip_purpose_raw, :string
  end
end
