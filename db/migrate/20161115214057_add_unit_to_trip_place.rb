class AddUnitToTripPlace < ActiveRecord::Migration
  def change
    add_column :trip_places, :unit, :string
  end
end
