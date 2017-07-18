module Export
  class ProviderSerializer < ActiveModel::Serializer

    attributes  :name, 
                :email,
                :url,
                :phone,
                :description
                
    def email
      object.email || object.internal_contact_email
    end

    def description
      object.comments.find_by(locale: "en").try(:comment)
    end
    
  end
end
