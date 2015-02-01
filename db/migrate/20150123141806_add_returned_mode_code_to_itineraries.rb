class AddReturnedModeCodeToItineraries < ActiveRecord::Migration
  def up
    add_column :itineraries, :returned_mode_code, :string



  end

  def down
    remove_column :itineraries, :returned_mode_code
  end
end



