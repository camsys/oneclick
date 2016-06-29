class AddSourceTagToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :source_tag, :string
  end
end
