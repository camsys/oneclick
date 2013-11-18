class AddTimeMismatchToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :date_mismatch, :boolean, :default => false
    add_column :itineraries, :time_mismatch, :boolean, :default => false
    add_column :itineraries, :too_late, :boolean, :default => false
  end

  def down
    remove_column :itineraries, :date_mismatch
    remove_column :itineraries, :time_mismatch
    remove_column :itineraries, :too_late
  end

end
