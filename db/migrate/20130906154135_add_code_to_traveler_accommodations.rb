class AddCodeToTravelerAccommodations < ActiveRecord::Migration
  def change
    add_column :traveler_accommodations, :code, :string
  end
end
