class AddGeocodeResultsTemporarily < ActiveRecord::Migration
  def change
    add_column :trip_places, :geocoding_raw, :string, limit: 2500
    add_column :user_places, :geocoding_raw, :string, limit: 2500
  end
end
