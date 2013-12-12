class AddSelectedToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :selected, :boolean, :default => false
  end

  def down
    remove_column :itineraries, :selected
  end
end
