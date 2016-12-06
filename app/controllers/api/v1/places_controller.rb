module Api
  module V1
    class PlacesController < Api::V1::ApiController

      def search
        #Get the Search String
        search_string = params[:search_string]
        include_user_pois = params[:include_user_pois]
        max_results = (params[:max_results] || 5).to_i

        locations = []
        count = 0

        #Check for exact match on stop code
        #Cut out white space and remove wildcards
        stripped_string = search_string.tr('%', '').strip.to_s + '%'
        if stripped_string.length >= 4 #Only check once 3 numbers have been entered
          stops = Poi.stops.where('stop_code LIKE ?', stripped_string).limit(max_results).to_a
          locations += stops
        end

        #Check for exact match on Google Place ID
        stripped_string = search_string.tr('%', '').strip.to_s
        stops = Poi.where(google_place_id: stripped_string).to_a
        locations += stops

        #Check for Stop Names
        stripped_string = search_string.tr('%', '').strip.to_s
        matching_stops = Poi.get_stops_by_str(stripped_string, max_results).to_a
        locations += matching_stops

        # Global POIs
        count = 0
        pois = Poi.get_by_query_str(search_string, max_results, true).to_a
        locations +=  pois

        locations_hash = []

        locations.uniq.each do |location|
          locations_hash.append(location.build_place_details_hash)
        end

        hash = {places_search_results: {locations: locations_hash}, record_count: locations.count}
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

      def boundary
        gs =  GeographyServices.new
        if gs.global_boundary_exists?
          render json: gs.global_boundary_as_geojson
          return
        end

        render :status => 404, json: {message: 'No Global Boundary'}
      end

      def routes
        tp = TripPlanner.new
        render status: 200, json: {routes: tp.get_routes}
        return
      end

      def synonyms
        synonyms = OneclickConfiguration.find_by(code: 'synonyms')
        unless synonyms.nil?
          synonyms = synonyms.value
        end
        synonyms.delete_if do |key, value| 
          value.split.include? key
        end
        render status: 200, json: synonyms.as_json
      end

      def blacklist
        blacklist = OneclickConfiguration.find_by(code: 'blacklisted_places')
        if blacklist.nil?
          blacklist = []
        else
          blacklist = blacklist.value
        end
        render status: 200, json: blacklist.as_json
      end

    end
  end
end