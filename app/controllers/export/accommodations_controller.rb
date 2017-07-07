module Export
  class AccommodationsController < Export::ExportApiController
    def index
      render json: {accommodations: "yo!"}
    end
  end
end