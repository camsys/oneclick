class AddNongeocodedAddressToPlace < ActiveRecord::Migration
  def change
    add_column :trip_places, :nongeocoded_address, :string
    add_column :user_places, :nongeocoded_address, :string
  end
end
