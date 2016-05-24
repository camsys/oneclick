class AddDesiredModesRawToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :desired_modes_raw, :string
  end
end
