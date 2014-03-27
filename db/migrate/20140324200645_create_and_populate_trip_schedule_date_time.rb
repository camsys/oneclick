class CreateAndPopulateTripScheduleDateTime < ActiveRecord::Migration
  def up
    add_column :trips, :scheduled_datetime, :datetime
    add_column :trip_parts, :scheduled_datetime, :datetime
    execute "update trips set scheduled_datetime = (CAST(scheduled_date as timestamp) + CAST(scheduled_time as TIME));"
    execute "update trip_parts set scheduled_datetime = (CAST(scheduled_date as timestamp) + CAST(scheduled_time as TIME));"

  end

  def down
    execute "update trips set scheduled_time = CAST(scheduled_datetime as time);"
    execute "update trip_parts set scheduled_time = CAST(scheduled_datetime as TIME));"
    remove_column :trips, :scheduled_datetime
    remove_column :trip_parts, :scheduled_datetime
  end
end
