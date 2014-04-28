class AddNameToTripPlace < ActiveRecord::Migration
  def change
    add_column :trip_places, :name, :string, limit: 256
  end
end
