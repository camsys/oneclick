class AddGeocodedAddressToTripPlace < ActiveRecord::Migration
  def up
    add_column :trip_places, :address1, :string, :limit => 128
    add_column :trip_places, :address2, :string, :limit => 128
    add_column :trip_places, :city, :string, :limit => 128
    add_column :trip_places, :state, :string, :limit => 2
    add_column :trip_places, :zip, :string, :limit => 10
  end

  def down
    remove_column :trip_places, :address1
    remove_column :trip_places, :address2
    remove_column :trip_places, :city
    remove_column :trip_places, :state
    remove_column :trip_places, :zip
  end
end
