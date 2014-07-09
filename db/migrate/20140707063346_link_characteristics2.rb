class LinkCharacteristics2 < ActiveRecord::Migration
  def change
    rename_column :service_characteristics, :rel_code, :rel_code
    rename_column :service_trip_purpose_maps, :rel_code, :rel_code    
    reversible do |dir|
      dir.up do
        age = Characteristic.where(code: 'age').first
        dob = Characteristic.where(code: 'date_of_birth').first
        age.update_attributes!(for_traveler: false, linked_characteristic: dob, link_handler: 'AgeCharacteristicHandler') rescue puts "age.update_attributes! failed"
        dob.update_attributes!(for_service: false, linked_characteristic: age, link_handler: 'AgeCharacteristicHandler') rescue puts "dob.update_attributes! failed"
      end
      dir.down do
        # nothing
      end
    end
  end
end
