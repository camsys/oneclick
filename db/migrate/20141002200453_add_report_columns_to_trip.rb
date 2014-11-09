class AddReportColumnsToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :agency_id, :integer
    add_column :trips, :outbound_provider_id, :integer
    add_column :trips, :return_provider_id, :integer
  end
end
