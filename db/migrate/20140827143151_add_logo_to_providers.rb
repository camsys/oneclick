class AddLogoToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :logo, :string
    remove_column :providers, :logo_url
  end
end
