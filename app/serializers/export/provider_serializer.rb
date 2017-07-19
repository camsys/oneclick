module Export
  class ProviderSerializer < ExportSerializer

    attributes  :name, 
                :email,
                :url,
                :phone,
                :comments
                
    uniquize_attribute :name
    
    def email
      object.email || object.internal_contact_email
    end

    def comments
      object.comments.map {|c| [c.locale, c.comment]}.to_h
    end
    
  end
end
