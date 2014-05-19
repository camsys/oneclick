class AddDurationEstimatedFlag < ActiveRecord::Migration
  def change
    add_column :itineraries, :duration_estimated, :boolean, default: false
  end
end
