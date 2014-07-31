class AllowNullValueAccommodationsAndTripPurpose < ActiveRecord::Migration
  def change
    change_column_null(:service_accommodations, :value, true)
    change_column_null(:service_trip_purpose_maps, :value, true)
  end
end
