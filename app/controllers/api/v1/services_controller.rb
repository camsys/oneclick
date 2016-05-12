module Api
  module V1
    class ServicesController < Api::V1::ApiController

      def ids
        external_id_array = []

        Service.paratransit.active.each do |service|
          external_id_array << service.external_id
        end

        hash = {service_ids: external_id_array}
        respond_with hash

      end

      def ids_humanized

        external_id_array = []

        Service.paratransit.active.each do |service|
          external_id_array << service.external_id.humanize
        end

        hash = {service_ids: external_id_array}
        respond_with hash

      end

    end
  end
end