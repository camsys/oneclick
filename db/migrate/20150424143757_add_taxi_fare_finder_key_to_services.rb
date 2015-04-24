class AddTaxiFareFinderKeyToServices < ActiveRecord::Migration
  def change
    add_column :services, :taxi_fare_finder_key, :string
  end
end
