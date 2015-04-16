module Api
  module V1
    class TripPurposesController < Api::V1::ApiController

      def index
        purposes = []
        TripPurpose.all.each do |tp|
          purposes.append({name: I18n.t(tp.name), code: tp.code, sort_order: tp.sort_order})
        end

        hash = {trip_purposes: purposes}
        respond_with hash
      end

      def list
        index
      end

    end
  end
end