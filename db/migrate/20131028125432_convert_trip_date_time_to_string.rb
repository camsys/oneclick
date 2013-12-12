class ConvertTripDateTimeToString < ActiveRecord::Migration
  def up
    remove_column :trip_parts, :trip_time
    add_column :trip_parts, :scheduled_date, :date, :after => :sequence
    add_column :trip_parts, :scheduled_time, :time, :after => :scheduled_date
  end

  def down
    remove_column :trip_parts, :scheduled_date
    remove_column :trip_parts, :scheduled_time
    add_column :trip_parts, :trip_time, :datetime, :after => :sequence
  end
end
