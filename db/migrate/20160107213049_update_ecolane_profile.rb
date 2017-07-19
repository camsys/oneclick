class UpdateEcolaneProfile < ActiveRecord::Migration
  def change
    add_column :ecolane_profiles, :endpoint, :string
    add_column :ecolane_profiles, :system, :string
    add_column :ecolane_profiles, :token, :string
  end
end
