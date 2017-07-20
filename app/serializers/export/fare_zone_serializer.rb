module Export
  class FareZoneSerializer < ExportSerializer
    
    attributes :name, :geom
    
    def name
      "#{object.service.name}_zone_#{object.zone_id}".underscore
    end
    
    def geom
      object.geom.to_s
    end
    
  end
end
