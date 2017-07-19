class RemoveEndpointFromEcolaneProfiles < ActiveRecord::Migration
  def change
    remove_column :ecolane_profiles, :endpoint, :string
  end
end
