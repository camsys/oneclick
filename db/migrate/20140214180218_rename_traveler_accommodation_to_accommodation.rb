class RenameTravelerAccommodationToAccommodation < ActiveRecord::Migration
  def up
    rename_table :traveler_accommodations, :accommodations
  end

  def down
    rename_table :accommodations, :traveler_accommodations
  end
end
