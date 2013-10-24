class AddTypeToTravelerCharacteristic < ActiveRecord::Migration
  def up
    add_column :traveler_characteristics, :characteristic_type, :string, :limit => 128
  end

  def down
    remove_column :traveler_characteristics, :characteristic_type
  end

end
