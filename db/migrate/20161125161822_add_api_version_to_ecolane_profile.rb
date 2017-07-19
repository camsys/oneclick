class AddApiVersionToEcolaneProfile < ActiveRecord::Migration
  def change
    add_column :ecolane_profiles, :api_version, :string, :null => false, :default => "8"
  end
end
