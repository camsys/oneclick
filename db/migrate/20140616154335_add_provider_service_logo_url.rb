class AddProviderServiceLogoUrl < ActiveRecord::Migration
  def change
    add_column :providers, :logo_url, :string
    add_column :services, :logo_url, :string
    add_column :modes, :logo_url, :string
  end
end
