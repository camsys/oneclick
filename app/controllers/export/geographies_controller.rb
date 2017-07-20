module Export
  class GeographiesController < Export::ExportApiController

    def fare_zones
      render json: FareZone.all.map{ |fz| FareZoneSerializer.new(fz).serializable_hash }
    end

  end
end
