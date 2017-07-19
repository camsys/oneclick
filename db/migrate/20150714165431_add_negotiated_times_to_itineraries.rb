class AddNegotiatedTimesToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :negotiated_pu_time, :datetime
    add_column :itineraries, :negotiated_do_time, :datetime
  end
end
