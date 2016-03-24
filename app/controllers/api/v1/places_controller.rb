module Api
  module V1
    class PlacesController < Api::V1::ApiController

      def search
        #Get the Search String
        search_string = params[:search_string]
        include_user_pois = params[:include_user_pois]
        max_results = (params[:max_results] || 10).to_i

        locations = []
        count = 0

        if include_user_pois.to_bool
          rel = Place.arel_table[:name].matches(search_string)
          places = @traveler.places.active.where(rel)
          places.each do |place|
            locations.append(place.build_place_details_hash)
            count += 1
            if count >= max_results
              break
            end
          end
        end

        # Global POIs
        pois = Poi.get_by_query_str(search_string, max_results, true)
        pois.each do |poi|
          locations.append(poi.build_place_details_hash)
          count += 1
          if count >= max_results
            break
          end

        end

        hash = {places_search_results: {locations: locations}, record_count: locations.count}
        respond_with hash

      end

      def within_area
        origin = params[:geometry]
        lat = origin[:location][:lat]
        lng = origin[:location][:lng]

        gs = GeographyServices.new
        if gs.global_boundary_exists?
          render json: {result: gs.within_global_boundary?(lat,lng)}
          return
        end

        Service.active.paratransit.each do |service |
          if service.endpoint_contains?(lat,lng)
            render json: {result: true}
            return
          end
        end
        render json: {result: false}
      end

    end
  end
end