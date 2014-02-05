class ChangeScheduleTimeToInt < ActiveRecord::Migration

  def up
    add_column :schedules, :start_seconds, :integer
    Schedule.all.each do |s|
      s.start_seconds = s.start_time.seconds_since_midnight
      s.save
    end

  end

  def down
    remove_column :schedules, :start_seconds

  end

end
