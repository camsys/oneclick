module Export
  class TripPurposesController < Export::ExportApiController
    def index
      render json: TripPurpose.all.map{ |p| TripPurposeSerializer.new(p).serializable_hash }
    end
  end
end