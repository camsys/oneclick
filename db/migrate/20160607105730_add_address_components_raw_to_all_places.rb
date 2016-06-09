class AddAddressComponentsRawToTripPlaces < ActiveRecord::Migration
  def change
    add_column :trip_places, :address_components_raw, :text
  end
end
