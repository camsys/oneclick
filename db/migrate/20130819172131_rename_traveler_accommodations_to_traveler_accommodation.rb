class RenameTravelerAccommodationsToTravelerAccommodation < ActiveRecord::Migration
  def up
    rename_table :traveler_accommodations, :traveler_accommodations
  end

  def down
    rename_table :traveler_accommodations, :traveler_accommodations
  end
end
