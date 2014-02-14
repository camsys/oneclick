class RenameServiceTravelerCharacteristicsMapToServiceCharacteristic < ActiveRecord::Migration
  def up
    rename_table :service_traveler_characteristics_maps, :service_characteristics
  end

  def down
    rename_table :service_characteristics, :service_traveler_characteristics_maps
  end
end
