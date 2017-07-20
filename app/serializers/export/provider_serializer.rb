module Export
  class ProviderSerializer < ExportSerializer

    attributes  :name, 
                :email,
                :url,
                :phone,
                :comments,
                :logo
                
    uniquize_attribute :name
    
    def email
      object.email || object.internal_contact_email
    end

    def comments
      object.comments.map {|c| [c.locale, c.comment]}.to_h
    end
    
    def logo
      object.try(:logo_url)
    end
    
  end
end
