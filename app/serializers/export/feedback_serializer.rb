module Export
  class FeedbackSerializer < ExportSerializer

    attributes  :user_id, 
                :email, 
                :rating, 
                :review, 
                :acknowledged, 
                :created_at, 
                :updated_at
    
    
    def email
      object.user_email
    end
    
    def rating
      object.average_rating
    end
    
    def review
      object.comment
    end
    
    def acknowledged
      ["approved", "rejected"].include?(object.status.try(:name))
    end

  end
end
