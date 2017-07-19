class AddGooglePlaceIdToPoi < ActiveRecord::Migration
  def change
    add_column :pois, :google_place_id, :string
  end
end
