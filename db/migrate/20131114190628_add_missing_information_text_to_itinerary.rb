class AddMissingInformationTextToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :missing_information_text, :text
  end

  def down
    remove_column :itineraries, :missing_information_text
  end

end
