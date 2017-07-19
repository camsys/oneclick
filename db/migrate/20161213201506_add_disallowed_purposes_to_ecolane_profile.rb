class AddDisallowedPurposesToEcolaneProfile < ActiveRecord::Migration
  def change
    add_column :ecolane_profiles, :disallowed_purposes, :text
  end
end
