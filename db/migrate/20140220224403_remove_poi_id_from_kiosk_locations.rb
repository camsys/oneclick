class RemovePoiIdFromKioskLocations < ActiveRecord::Migration
  def change
    remove_column :kiosk_locations, :poi_id
  end
end
