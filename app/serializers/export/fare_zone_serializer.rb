module Export
  class FareZoneSerializer < GeographySerializer
            
    def name
      "#{object.service.name}_zone_#{object.zone_id}".underscore
    end
        
  end
end
