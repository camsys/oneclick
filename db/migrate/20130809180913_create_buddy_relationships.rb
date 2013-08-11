class CreateBuddyRelationships < ActiveRecord::Migration
  def change
    create_table :buddy_relationships do |t|
      t.integer :buddy_id
      t.string :status
      t.string :email_address
      t.datetime :email_sent
      t.integer :traveler_id

      t.timestamps
    end
    add_index :buddy_relationships, [:traveler_id, :email_address], :unique => true    
  end
end
