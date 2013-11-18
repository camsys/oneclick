class AddMissingAccommodationsToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :missing_accommodations, :string, :default => ''
  end

  def down
    remove_column :itineraries, :missing_accommodations
  end
end
