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
      r = object.average_rating
      
      if r.is_a?(Numeric)
        return [[0, r].max, 5].min
      else
        return r
      end
      
    end
    
    def review
      object.comment
    end
    
    def acknowledged
      ["approved", "rejected"].include?(object.status.try(:name))
    end

  end
end
