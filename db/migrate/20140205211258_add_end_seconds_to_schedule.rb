class AddEndSecondsToSchedule < ActiveRecord::Migration
  def up
    add_column :schedules, :end_seconds, :integer
  end

  def down
    remove_column :schedules, :end_seconds
  end
end
