class AddEndSecondsToSchedule < ActiveRecord::Migration
  def up
    add_column :schedules, :end_seconds, :integer
    Schedule.all.each do |s|
      s.end_seconds = s.end_time.in_time_zone.seconds_since_midnight
      s.save
    end

  end

  def down
    remove_column :schedules, :end_seconds

  end
end
