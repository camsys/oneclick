class ChangeItineraryStartTimeEndTimeToDateTimes < ActiveRecord::Migration
  def up
    remove_column :itineraries, :start_time
    remove_column :itineraries, :end_time
    add_column :itineraries, :start_time, :datetime
    add_column :itineraries, :end_time, :datetime
  end

  def down
    remove_column :itineraries, :start_time
    remove_column :itineraries, :end_time
    add_column :itineraries, :start_time, :time
    add_column :itineraries, :end_time, :time
  end

end
