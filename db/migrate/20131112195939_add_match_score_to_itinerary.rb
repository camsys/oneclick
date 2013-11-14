class AddMatchScoreToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :match_score, :float, :default => 0
  end

  def down
    remove_column :itineraries, :match_score
  end

end

