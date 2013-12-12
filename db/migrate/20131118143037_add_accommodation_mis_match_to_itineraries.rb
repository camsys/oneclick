class AddAccommodationMisMatchToItineraries < ActiveRecord::Migration
  def up
    rename_column :itineraries, :partial_match, :accommodation_mismatch
  end

  def down
    rename_column :itineraries, :accommodation_mismatch, :partial_match
  end
end
