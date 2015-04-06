module Api
  module V1
    class PlacesController < ApplicationController
      respond_to :json
      require 'json'

      def search
        #Get the Search String
        search_string = params[:search_string]
        include_user_pois = params[:include_user_pois]
        max_results = (params[:max_results] || 10).to_i

        locations = []
        count = 0

        #Private Places
        traveler_id = params[:traveler_id]
        if traveler_id and include_user_pois.to_bool
          @traveler = User.find(traveler_id.to_i)
          rel = Place.arel_table[:name].matches(search_string + "%")
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
        pois = Poi.get_by_query_str(search_string + '%', max_results)
        pois.each do |poi|
          locations.append(poi.build_place_details_hash)
          count += 1
          if count >= max_results
            break
          end

        end

        hash = {poi_search_results: {locations: locations}}
        respond_with hash

      end

    end
  end
end