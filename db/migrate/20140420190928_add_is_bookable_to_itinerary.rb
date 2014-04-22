class AddIsBookableToItinerary < ActiveRecord::Migration
  def change
    add_column :itineraries, :is_bookable, :boolean, default: false, null: false
  end
end
