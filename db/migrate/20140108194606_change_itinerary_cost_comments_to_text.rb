class ChangeItineraryCostCommentsToText < ActiveRecord::Migration
  def up
    change_column :itineraries, :cost_comments, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :itineraries, :cost_comments, :string
  end
end
