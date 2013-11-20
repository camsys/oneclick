class AddCostCommentsToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :cost_comments, :string
  end

  def down
    remove_column :itineraries, :cost_comments
  end
end
