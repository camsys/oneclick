module Export
  class AccommodationsController < Export::ExportApiController
    def index
      accs = []
      Accommodation.all.each do |acc|
        accs << AccommodationSerializer.new(acc).serializable_hash
      end
      render json: accs
    end
  end
end