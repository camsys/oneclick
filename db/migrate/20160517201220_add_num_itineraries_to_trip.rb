class AddNumItinerariesToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :num_itineraries, :integer, :default => 3
  end
end
