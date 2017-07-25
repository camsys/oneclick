module Export
  class UserSerializer < ExportSerializer

    attributes  :email, 
                :first_name, 
                :last_name, 
                :encrypted_password, 
                :created_at,
                :updated_at,
                :preferred_locale,
                :last_sign_in_at,
                :current_sign_in_at,
                :accommodations,
                :characteristics,
                :preferred_modes,
                :places
                
    uniquize_attribute :email

    def accommodations
      object.user_accommodations.map do |ua| 
        [ua.accommodation.code, ua.value.to_bool]
      end.to_h
    end
    
    def characteristics
      object.user_characteristics.map do |uc| 
        [uc.characteristic.code, uc.value.to_bool]
      end.to_h
    end
    
    def preferred_modes
      object.preferred_modes.pluck(:code)
    end

    def places
      object.places.map{ |obj| PlaceSerializer.new(obj).serializable_hash }
    end

  end
end
