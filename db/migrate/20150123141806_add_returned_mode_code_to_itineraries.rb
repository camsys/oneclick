class AddReturnedModeCodeToItineraries < ActiveRecord::Migration
  def up
    add_column :itineraries, :returned_mode_code, :string

    Itinerary.all.each do |itin|
      if !itin.mode 
        next
      end

      returned_mode_code = itin.mode.code
      if returned_mode_code == "mode_transit"
        if itin.is_walk
          returned_mode_code = Mode.walk.code
        elsif itin.is_car
          returned_mode_code = Mode.car.code
        elsif itin.is_bicycle
          returned_mode_code = Mode.bicycle.code
        end
      end
      
      itin.update_attribute(:returned_mode_code, returned_mode_code)
    end
  end

  def down
    remove_column :itineraries, :returned_mode_code
  end
end
