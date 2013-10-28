class DropPlannedTripsTable < ActiveRecord::Migration
  def up
    if connection.tables.include?('planned_trips')
        drop_table :planned_trips
    end    
  end

  def down
  end
end
