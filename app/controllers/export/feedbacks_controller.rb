module Export
  class FeedbacksController < Export::ExportApiController
  
    def index
      render json: Feedback.all.map{ |fb| FeedbackSerializer.new(fb).serializable_hash }
    end
    
  end
end
