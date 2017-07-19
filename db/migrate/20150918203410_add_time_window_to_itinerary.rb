class AddTimeWindowToItinerary < ActiveRecord::Migration
  def change
    add_column :itineraries, :negotiated_pu_window_start, :datetime
    add_column :itineraries, :negotiated_pu_window_end, :datetime
  end
end
