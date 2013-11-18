class AddMissingInformationToItinerary < ActiveRecord::Migration

  def up
    add_column :itineraries, :missing_information, :boolean, :default => false
    add_column :itineraries, :partial_match, :boolean, :default => false
  end

  def down
    remove_column :itineraries, :missing_information
    remove_column :itineraries, :partial_match
  end

end
