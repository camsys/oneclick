module Export
  class TripsController < Export::ExportApiController
    
    # Send a batch of trips as designated by batch_size and batch_index params
    def index
      batch_index = params[:batch_index].try(:to_i) || 0
      batch_size = params[:batch_size].try(:to_i) || 50
      render json:  TripPart.order(:id)
                            .limit(batch_size)
                            .offset(batch_size * batch_index)
                            .map{ |tp| TripPartSerializer.new(tp).serializable_hash }
    end
    
  end
end
