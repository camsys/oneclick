class ChangeTripScheduleTimeToDateTime < ActiveRecord::Migration
  def up
    remove_column :trips, :scheduled_time
    remove_column :trip_parts, :scheduled_time
    add_column :trips, :scheduled_time, :datetime
    add_column :trip_parts, :scheduled_time, :datetime
  end

  def down
    remove_column :trips, :scheduled_time
    remove_column :trip_parts, :scheduled_time
    add_column :trips, :scheduled_time, :time
    add_column :trip_parts, :scheduled_time, :time
  end

end
