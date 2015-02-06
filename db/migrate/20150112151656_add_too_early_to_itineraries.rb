class AddTooEarlyToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :too_early, :boolean, :default => false
  end
end
