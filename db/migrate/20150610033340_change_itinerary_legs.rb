class ChangeItineraryLegs < ActiveRecord::Migration
  def change
  	rename_column :itineraries, :legs, :raw_otp_itinerary
  end
end
