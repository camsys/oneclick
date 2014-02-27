class RenameUserTravelerAccommodationsMapToUserAccommodation < ActiveRecord::Migration
  def up
    rename_table :user_traveler_accommodations_maps, :user_accommodations
  end

  def down
    rename_table :user_accommodations, :user_traveler_accommodations_maps
  end
end
