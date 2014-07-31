class RemoveProviderOrgFromProvider < ActiveRecord::Migration
  def change
    remove_reference :providers, :provider_org
  end
end
