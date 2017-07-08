module Export
  class AccommodationsController < Export::ExportApiController
    def index
      render json: Accommodation.all.map{ |obj| AccommodationSerializer.new(obj).serializable_hash }
    end
  end
end