class AddMapImage < ActiveRecord::Migration
  def change
    add_column :itineraries, :map_image, :string
  end
end
