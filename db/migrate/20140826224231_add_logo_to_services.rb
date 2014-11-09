class AddLogoToServices < ActiveRecord::Migration
  def change
    add_column :services, :logo, :string
    remove_column :services, :logo_url
  end
end
