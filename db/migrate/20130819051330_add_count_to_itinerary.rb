class AddCountToItinerary < ActiveRecord::Migration
  def change
    add_column :itineraries, :count, :integer
  end
end
