module Export
  class ZipcodeSerializer < GeographySerializer
                
    def name
      object.zipcode
    end
            
  end
end
