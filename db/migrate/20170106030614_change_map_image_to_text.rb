class ChangeMapImageToText < ActiveRecord::Migration
  def up
    change_column :itineraries, :map_image, :text
  end

  def down
    change_column :itineraries, :map_image, :string
  end
end
