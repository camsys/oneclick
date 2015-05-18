class AddTokenToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :token, :string
    add_column :trips, :agency_token, :string
  end
end
