class AddGeocodeResultsTemporarily < ActiveRecord::Migration
  def change
    add_column :places, :geocoding_raw, :string, limit: 2500
  end
end
