class AddRatingToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :rating, :integer
  end
end
