module Export
  class TripPlaceSerializer < ExportSerializer

    require 'street_address'

    attributes  :name,
                :street_number,
                :route,
                :city,
                :state,
                :zip,
                :lat,
                :lng

    uniquize_attribute :name
    
    def lng
      object.lon
    end
    
    def parsed_address
      StreetAddress::US.parse(object.address1.to_s.strip)
    end

    def street_number
      parsed_address.try(:number)
    end

    def route
      "#{parsed_address.try(:street)} #{parsed_address.try(:street_type)}"
    end

  end
end
