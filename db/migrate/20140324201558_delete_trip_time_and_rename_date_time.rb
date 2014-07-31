class DeleteTripTimeAndRenameDateTime < ActiveRecord::Migration
  def up
    remove_column :trips, :scheduled_time
    remove_column :trip_parts, :scheduled_time
    rename_column :trips, :scheduled_datetime, :scheduled_time
    rename_column :trip_parts, :scheduled_datetime, :scheduled_time
  end

  def down
    rename_column :trips, :scheduled_time, :scheduled_datetime
    rename_column :trip_parts, :scheduled_time, :scheduled_datetime
    add_column :trips, :schedule_time, :time
    add_column :trips_parts, :scheduled_time, :time
  end
end
