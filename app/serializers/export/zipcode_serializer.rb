module Export
  class ZipcodeSerializer < GeographySerializer
            
    attributes :state
    
    def name
      object.zipcode
    end
            
  end
end
