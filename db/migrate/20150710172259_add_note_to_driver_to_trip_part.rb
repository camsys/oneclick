class AddNoteToDriverToTripPart < ActiveRecord::Migration
  def change
    add_column :trip_parts, :note_to_driver, :text
  end
end
