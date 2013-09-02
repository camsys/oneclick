class RenameServiceTripPurposeMapPurposeIdTripPurposeId < ActiveRecord::Migration
  def up
    rename_column :service_trip_purpose_maps, :purpose_id, :trip_purpose_id
  end

  def down
  end
end
