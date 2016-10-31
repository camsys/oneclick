class AddFleetSizeAndTripVolumnToServices < ActiveRecord::Migration
  def change
    add_column :services, :fleet_size, :integer
    add_column :services, :trip_volume, :integer
  end
end
