class AddTagToTravelerCharacteristics < ActiveRecord::Migration
  def change
    add_column :traveler_characteristics, :code, :string
  end
end
