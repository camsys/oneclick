module Export
  class UserServiceSerializer < ExportSerializer
    
    attributes :user_id,
               :service_id,
               :booking_api,
               :details,
               :encrypted_external_password,
               :created_at
               
    def user_id
      object.user_profile.try(:user_id)
    end
    
    def booking_api
      booking_api_code = BookingServices::AGENCY.key(object.service.try(:booking_profile))
      case booking_api_code
      when :ridepilot
        return :ride_pilot
      else
        return booking_api_code
      end
    end
        
    def details
      case booking_api
      when :ride_pilot
        return {}
      when :ecolane
        return {}
      when :trapeze
        return {}
      else
        return nil
      end
    end
    
    def encrypted_external_password
      object.encrypted_user_password
    end

  end
end
