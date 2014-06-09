class AddPlannedTripHtmlToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :planned_trip_html, :text
  end
end
