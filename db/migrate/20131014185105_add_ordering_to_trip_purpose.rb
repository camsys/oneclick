class AddOrderingToTripPurpose < ActiveRecord::Migration
  def up
    add_column :trip_purposes, :sort_order, :integer
  end

  def down
    remove_column :trip_purposes, :sort_order
  end
end
