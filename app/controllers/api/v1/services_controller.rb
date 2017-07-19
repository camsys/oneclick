module Api
  module V1
    class ServicesController < Api::V1::ApiController

      def ids

        external_id_array = Service.paratransit.active.map do |service|
          if service.ecolane_profile && service.ecolane_profile.booking_counties
            service.ecolane_profile.booking_counties
          else
            []
          end
        end.flatten.sort

        hash = {service_ids: external_id_array}

        respond_with hash

      end

      # Returns a hash containing an array of prettified county names available for service booking
      def ids_humanized

        external_id_array = Service.paratransit.active.map do |service|
          if service.ecolane_profile && service.ecolane_profile.booking_counties
            service.ecolane_profile.booking_counties
          else
            []
          end
        end.flatten.map(&:humanize).uniq.sort

        hash = {service_ids: external_id_array}

        respond_with hash

      end

      def counties

        external_ids = {}
        Service.paratransit.active.each do |service|
          if service.ecolane_profile
            counties = service.ecolane_profile.booking_counties || []
            counties.each do |county|
              external_ids[county] = service.external_id
            end
          end
        end

        respond_with external_ids

      end

      #Given a registered traveler.  Return the dates/hours that are allowed for booking
      def hours

        today = Date.today
        hours = {}

        if @traveler.is_visitor? or @traveler.is_api_guest? #Return a wide range of hours

          (0..21).each do |n|
            hours[(today + n).to_s] = {open: "07:00", close: "22:00"}
          end

        else # This is not a guest, check to see if the traveler is registered with a service

          if @traveler.user_profile.user_services.count > 0 #This user is registered with a service
            user_service = @traveler.user_profile.user_services.first
            service = user_service.service
            min_notice_days = (service.advanced_notice_minutes || 1440).to_i / 1440 #Minimum notice in days
            max_notice_days = [(service.max_advanced_book_minutes || 20160).to_i / 1440, 28].min #Max advanced notice (up to 28 days)

            if user_service.unrestricted_hours #This user is allowed to book at all times
              (1..21).each do |n|
                hours[(today + n).to_s] = {open: "00:00", close: "23:59"}
              end
            elsif service.schedules.count > 0 #This user's service has listed hours

              (min_notice_days..max_notice_days).each do |n|
                schedule = service.schedules.where(day_of_week: (today + n).wday).first
                if schedule
                  hours[(today + n).to_s] = {open: schedule.start_string_24_hour, close: schedule.end_string_24_hour}
                end
              end

            else #This user is registered with a service, but that service has not entered any hours

              (min_notice_days..max_notice_days).each do |n|
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
