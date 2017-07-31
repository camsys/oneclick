module Export
  class PlaceSerializer < ExportSerializer

    require 'street_address'

    attributes  :name,
                :street_number,
                :route,
                :city,
                :state,
                :zip,
                :lat,
                :lon

    def street_number
      parsed_address.try(:number)
    end

    def route
      [ parsed_address.try(:street),
        parsed_address.try(:street_type) ].compact.join(' ')
    end
    
    private
    
    # helper method for parsing address
    def parsed_address
      StreetAddress::US.parse(object.address1.strip)
    end

  end
end
