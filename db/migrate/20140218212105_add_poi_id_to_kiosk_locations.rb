class AddPoiIdToKioskLocations < ActiveRecord::Migration
  def change
    add_column :kiosk_locations, :poi_id, :integer
  end
end
