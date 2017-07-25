module Export
  class GeographiesController < Export::ExportApiController

    def fare_zones
      render json: FareZone.all.map{ |fz| FareZoneSerializer.new(fz).serializable_hash }
    end
    
    def counties
      if table_exists?(:counties)
        @counties = params[:state].present? ? County.where(state: params[:state]) : County.all
      else
        @counties = []
      end
      render json: @counties.map{ |c| CountySerializer.new(c).serializable_hash }
    end
    
    def zipcodes
      if table_exists?(:zipcodes)
        @zipcodes = params[:state].present? ? Zipcode.where(state: params[:state]) : Zipcode.all
      else
        @zipcodes = []
      end
      render json: @zipcodes.map{ |z| ZipcodeSerializer.new(z).serializable_hash }
    end

    def cities
      if table_exists?(:cities)
        @cities = params[:state].present? ? City.where(state: params[:state]) : City.all
      else
        @cities = []
      end
      render json: @cities.map{ |c| CitySerializer.new(c).serializable_hash }
    end
    
    def table_exists?(table)
      ActiveRecord::Base.connection.table_exists?(table)
    end

  end
end
