class RemoveCountyArraysFromServices < ActiveRecord::Migration
  def up
    # First, copy data over into service's ecolane profile
    Rake::Task["oneclick:one_offs:transfer_endpoint_counties_to_ecolane_profiles"].invoke

    remove_column :services, :county_endpoint_array, :text
    remove_column :services, :county_coverage_array, :text
  end

  def down
    add_column :services, :county_endpoint_array, :text
    add_column :services, :county_coverage_array, :text
  end
end
