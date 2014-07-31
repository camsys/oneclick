class RemoveValueFromAccommodationsAndTripPurpose < ActiveRecord::Migration
  def change
    remove_column :service_accommodations, :value
    remove_column :service_trip_purpose_maps, :value
  end
end
