class AddGeocodedAddressToTripPlace < ActiveRecord::Migration
  def up
    add_column :trip_places, :address1, :string, :limit => 128
    add_column :trip_places, :address2, :string, :limit => 128
    add_column :trip_places, :city, :string, :limit => 128
    add_column :trip_places, :state, :string, :limit => 2
    add_column :trip_places, :zip, :string, :limit => 10
  end

  def down
    add_column :trip_places, :address1
    add_column :trip_places, :address2
    add_column :trip_places, :city
    add_column :trip_places, :state
    add_column :trip_places, :zip
  end
end
