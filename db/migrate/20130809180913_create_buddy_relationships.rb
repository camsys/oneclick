class CreateBuddyRelationships < ActiveRecord::Migration
  def change
    create_table :buddy_relationships do |t|
      t.integer :buddy_id
      t.string :status
      t.string :email_address
      t.integer :traveler_id

      t.timestamps
    end
  end
end
