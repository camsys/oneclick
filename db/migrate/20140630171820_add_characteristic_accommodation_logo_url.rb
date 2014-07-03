class AddCharacteristicAccommodationLogoUrl < ActiveRecord::Migration
  def change
    add_column :characteristics, :logo_url, :string
    add_column :accommodations, :logo_url, :string
  end
end
