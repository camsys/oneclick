class AddCountyTextCoverageAndEndpoint < ActiveRecord::Migration
  def change
    add_column :services, :county_endpoint_array, :text
    add_column :services, :county_coverage_array, :text
  end
end
