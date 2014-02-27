class RenameUserTravelerCharacteristicsMapToUserCharacteristic < ActiveRecord::Migration
  def up
    rename_table :user_traveler_characteristics_maps, :user_characteristics
  end

  def down
    rename_table :user_characteristics, :user_traveler_characteristics_maps
  end
end
