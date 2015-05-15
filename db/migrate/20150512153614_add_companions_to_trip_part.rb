class AddCompanionsToTripPart < ActiveRecord::Migration
  def change
    add_column :trip_parts, :assistant, :boolean
    add_column :trip_parts, :companions, :integer
    add_column :trip_parts, :children, :integer
    add_column :trip_parts, :other_passengers, :integer
  end
end
