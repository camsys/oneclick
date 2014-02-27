class RenameTravelerCharacteristicToCharacteristic < ActiveRecord::Migration
  def up
    rename_table :traveler_characteristics, :characteristics
  end

  def down
    rename_table :characteristics, :traveler_characteristics
  end
end
