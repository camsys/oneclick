class SetScaleAndPrecision < ActiveRecord::Migration
  def change
    change_column :pois, :lat, :decimal, :precision => 15, :scale => 10
    change_column :pois, :lon, :decimal, :precision => 15, :scale => 10
    change_column :trip_places, :lat, :decimal, :precision => 15, :scale => 10
    change_column :trip_places, :lon, :decimal, :precision => 15, :scale => 10
  end
end
