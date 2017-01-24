module Api
  module V1
    class UsersController < Api::V1::ApiController

      def update
        @traveler.update_profile params
        valid = @traveler.valid?
        response = {}
        #Update accommodations and characteristics
        bs = BookingServices.new
        # If booking params are sent, run associate user with that info.
        if params["booking"]
          booking_authenticated = params["booking"].all? do |booking|
            bs.associate_user(Service.find(booking["service_id"]), @traveler, booking["user_name"], booking["password"])[0]
          end
          booking_message = booking_authenticated ? "Third-party booking profile(s) successfully authenticated." : "Third-party booking authentication failed."
          response[:booking] = {result: booking_authenticated, message: booking_message}
        end

        if !valid
          Rails.logger.error(@traveler.errors.messages)
          response[:result] = false
          response[:message] = "Unable to update user profile due the following error: #{@traveler.errors.messages}"
        else
          @traveler.save
          response[:result] = true
          response[:message] = "User updated."
        end

        render json: response and return
      end

      def profile
        hash = {first_name: @traveler.first_name, last_name: @traveler.last_name}

        #Don't send an email address if it's just the default ecolane email
        email = @traveler.email
        if email.include? "@ecolane_user.com"
          email = ""
        end
        hash[:email] =  email

        #Walking Speed
        walking_speed = @traveler.walking_speed
        unless walking_speed.nil?
          hash[:walking_speed] = walking_speed.code
        else
          hash[:walking_speed] = "average"
        end

        #Walking Distance
        walking_distance = @traveler.walking_maximum_distance
        unless walking_distance.nil?
          hash[:walking_distance] = walking_distance.value
        else
          hash[:walking_distance] = 2.0
        end

        #Ecolane Id
        user_service = @traveler.user_profile.user_services.first #there should only ever be one
        unless user_service.nil?
          hash[:ecolane_id] = user_service.external_user_id
        else
          hash[:ecolane_id] = nil
        end

        hash[:lang] = @traveler.preferred_locale
        hash[:characteristics] = @traveler.characteristics_hash
        hash[:accommodations] = @traveler.accommodations_hash
        hash[:preferred_modes] = @traveler.preferred_modes_hash

        render json: hash

      end

      def get_guest_token
        guest = create_guest_user
        guest.reset_authentication_token!
        guest.save
        render json: {email: guest.email, authentication_token: guest.authentication_token}
        return
      end

      # Looks up user profile via an external booking service
      # booking_agency param determines if using Ecolane, RidePilot, etc.
      def lookup
        booking_agency = params[:booking_agency] || nil
        result = BookingServices.new.query_user_external_id(booking_agency, params)
        if result[:customer_number]
          render json: result
        else
          render json: {message: result[:message] }, status: 404
        end
      end

    end
  end
end
