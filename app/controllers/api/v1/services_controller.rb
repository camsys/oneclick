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

        today = Date.today
        hours = {}

        if @traveler.is_visitor? #Return a wide range of hours

          (0..21).each do |n|
            hours[(today + n).to_s] = {open: "08:00", close: "17:00"}
          end

        else # This is not a guest, check to see if the traveler is registered with a service

          if @traveler.user_profile.user_services.count > 0 #This user is registered with a service

            service = @traveler.user_profile.user_services.first.service
            if service.schedules.count > 0 #This user's service has listed hours

              (1..14).each do |n|
                schedule = service.schedules.where(day_of_week: (today + n).wday).first
                if schedule
                  hours[(today + n).to_s] = {open: schedule.start_string_24_hour, close: schedule.end_string_24_hour}
                end
              end

            else #This user is registered with a service, but that service has not entered any hours

              (1..14).each do |n|
                unless (today + n).saturday? or (today + n).sunday?
                  hours[(today + n).to_s] = {open: "08:00", close: "17:00"}
                end
              end

            end

          else #This user is logged in but isn't registered with a service

            (1..14).each do |n|
              unless (today + n).saturday? or (today + n).sunday?
                hours[(today + n).to_s] = {open: "08:00", close: "17:00"}
              end
            end

          end # if #traveler.user_profile.user_services.count > 0
        end # if @travler.is_visitor

        respond_with hours

      end #hours

    end
  end
end