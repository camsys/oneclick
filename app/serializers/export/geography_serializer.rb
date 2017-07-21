module Export
  class GeographySerializer < ExportSerializer
    
    attributes :name, :geom
    
    def geom
      object.geom.to_s
    end
    
  end
end
