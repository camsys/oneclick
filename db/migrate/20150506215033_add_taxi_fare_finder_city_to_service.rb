class AddTaxiFareFinderCityToService < ActiveRecord::Migration
  def up
  	add_column :services, :taxi_fare_finder_city, :string, :limit => 64
  end
  def down
  	remove_column :services, :taxi_fare_finder_city
  end
end
