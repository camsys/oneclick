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

      #Given a registered traveler.  Return the dates/hours that are allowed for booking
      def hours
        #This is currently a placeholder
        today = Date.today
        hours = {}
        (1..14).each do |n|
          unless (today + n).saturday? or (today + n).sunday?
            hours[(today + n).to_s] = {open: "08:00", close: "17:00"}
          end
        end

        respond_with hours

      end

    end
  end
end