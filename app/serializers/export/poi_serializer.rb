module Export
  class PoiSerializer < ExportSerializer

    require 'street_address'

    attributes  :name,
                :street_number,
                :route,
                :city,
                :state,
                :zip,
                :lat,
                :lon

    uniquize_attribute :name

    def street_number
      StreetAddress::US.parse(object.address1).number
    end

    def route
      parsed = StreetAddress::US.parse(object.address1)
      "#{parsed.street} #{parsed.street_type}"
    end

  end
end
