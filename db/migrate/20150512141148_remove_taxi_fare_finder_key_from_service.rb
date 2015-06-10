class RemoveTaxiFareFinderKeyFromService < ActiveRecord::Migration
  def change
    rename :services, :taxi_fare_finder_key
  end
end
