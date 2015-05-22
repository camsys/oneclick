class AddGtfsColorBooleanToService < ActiveRecord::Migration
  def change
  	add_column :services, :use_gtfs_colors, :boolean
  end
end