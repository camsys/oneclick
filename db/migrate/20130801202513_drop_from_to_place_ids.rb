class DropFromToPlaceIds < ActiveRecord::Migration
  def change
    remove_column :trips, :from_place_id
    remove_column :trips, :to_place_id
  end
end
