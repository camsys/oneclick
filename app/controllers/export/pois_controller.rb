module Export
  class PoisController < Export::ExportApiController
    def index
      render json: Poi.all.map{ |obj| PoiSerializer.new(obj).serializable_hash }
    end
  end
end