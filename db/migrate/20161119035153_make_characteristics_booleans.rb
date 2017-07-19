class MakeCharacteristicsBooleans < ActiveRecord::Migration
  def change
    rename_column :user_characteristics, :value, :old_value
    add_column :user_characteristics, :value, :boolean

    UserCharacteristic.all.each do |uc|
      if uc.old_value == "true"
        uc.value = true
      else
        uc.value = false
      end
      uc.save!
    end

    remove_column :user_characteristics, :old_value

  end
end
