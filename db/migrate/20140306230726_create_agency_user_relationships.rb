class CreateAgencyUserRelationships < ActiveRecord::Migration
  def change
    create_table :agency_user_relationships do |t|
        t.belongs_to :agency, null: false
        t.belongs_to :user, null: false
        t.integer :relationship_status_id, null: false, default: 3
      t.timestamps
    end
  end
end
