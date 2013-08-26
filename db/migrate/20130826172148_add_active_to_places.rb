class AddActiveToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :active, :boolean, :default => true
  end
end
