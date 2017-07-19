class RemoveDisallowedPurposesFromService < ActiveRecord::Migration
  def change
    # Copy over data from disallowed purposes arrays to Ecolane Profiles before removing the column
    Rake::Task["oneclick:one_offs:transfer_disallowed_purposes_to_ecolane_profiles"].invoke
    remove_column :services, :disallowed_purposes, :text
  end
end
