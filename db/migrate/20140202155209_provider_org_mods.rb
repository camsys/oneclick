class ProviderOrgMods < ActiveRecord::Migration
  def change
    # rename_column :organizations, :org_type, :type
    add_column :providers, :provider_org_id, :integer
  end

end
