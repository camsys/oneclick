class AddCountItineraryAndMode < ActiveRecord::Migration
  def up
    add_column :itineraries, :ride_count, :integer
    add_column :itineraries, :external_info, :text
    Mode.create!(name: 'Rideshare', active: true)
  end

  def down
    remove_column :itineraries, :ride_count
    remove_column :itineraries, :external_info
  end
end
