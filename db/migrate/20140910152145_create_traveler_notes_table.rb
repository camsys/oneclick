class CreateTravelerNotesTable < ActiveRecord::Migration
  def change
    create_table :traveler_notes do |t|
      t.integer :user_id
      t.integer :agency_id
      t.text :note
    end
  end
end
