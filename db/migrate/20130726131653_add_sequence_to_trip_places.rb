class AddSequenceToTripPlaces < ActiveRecord::Migration
  def change
    add_column :trip_places, :sequence, :integer
  end

end
