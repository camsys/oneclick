module Export
  class GeographiesController < Export::ExportApiController

    def fare_zones
      render json: FareZone.all.map{ |fz| FareZoneSerializer.new(fz).serializable_hash }
    end
    
    def counties
      @counties = params[:state].present? ? County.where(state: params[:state]) : County.all
      render json: @counties.map{ |c| CountySerializer.new(c).serializable_hash }
    end
    
    def zipcodes
      @zipcodes = params[:state].present? ? Zipcode.where(state: params[:state]) : Zipcode.all
      render json: @zipcodes.map{ |z| ZipcodeSerializer.new(z).serializable_hash }
    end

    def cities
      @cities = params[:state].present? ? City.where(state: params[:state]) : City.all
      render json: @cities.map{ |c| CitySerializer.new(c).serializable_hash }
    end

  end
end
