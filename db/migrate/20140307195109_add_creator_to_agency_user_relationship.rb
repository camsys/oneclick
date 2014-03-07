class AddCreatorToAgencyUserRelationship < ActiveRecord::Migration
  def change
    add_column :agency_user_relationships, :creator, :integer, null: false
  end
end
