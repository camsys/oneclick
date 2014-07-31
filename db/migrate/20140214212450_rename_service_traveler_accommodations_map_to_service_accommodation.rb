class RenameServiceTravelerAccommodationsMapToServiceAccommodation < ActiveRecord::Migration
  def up
    rename_table :service_traveler_accommodations_maps, :service_accommodations
  end

  def down
    rename_table :service_accommodations, :service_traveler_accommodations_maps
  end
end
