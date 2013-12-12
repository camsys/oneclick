class AddDescToCharacteristics < ActiveRecord::Migration
  def up
    add_column :traveler_characteristics, :desc, :string, :default => ''
  end

  def down
    remove_column :traveler_characteristics, :desc
  end
end
