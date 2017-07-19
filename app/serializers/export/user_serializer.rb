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
                :authentication_token,
                :accommodations,
                :characteristics,
                :preferred_modes
                
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

  end
end
