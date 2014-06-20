class AddAskEarlyToCharacteristics < ActiveRecord::Migration
  def change
    add_column :characteristics, :ask_early, :boolean, default: true
    add_column :accommodations, :ask_early, :boolean, default: true
    reversible do |dir|
      dir.up do
        Characteristic.where(code: 'veteran').first.update_attribute(:ask_early, false) if Characteristic.exists?(code: 'veteran')
        Accommodation.where(code: 'driver_assistance_available').first.update_attribute(:ask_early, false) if Accommodation.exists?(code: 'driver_assistance_available')
        Accommodation.where(code: 'companion_allowed').first.update_attribute(:ask_early, false) if Accommodation.exists?(code: 'companion_allowed')
      end
      dir.down do
        # nothing
      end
    end
  end
end
