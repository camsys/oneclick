class AddOrganizationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :agency_id, :integer
    add_column :users, :provider_id, :integer
  end
end
