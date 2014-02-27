class RemoveStartTimeAndEndTimeFromSchedules < ActiveRecord::Migration
  def up
    remove_column :schedules, :end_time
    remove_column :schedules, :start_time
  end

  def down
    remove_column :schedules, :end_time, :time
    remove_column :schedules, :start_time, :time
  end
end
