class RemoveTaxiFareFinderKeyFromService < ActiveRecord::Migration
  def change
    remove_column :services, :taxi_fare_finder_key
  end
end
