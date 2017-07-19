module Api
  module V1
    class UsersController < Api::V1::ApiController

      def update
        @traveler.update_profile params
        valid = @traveler.valid?
        response = {}
        #Update accommodations and characteristics
        # If booking params are sent, run associate user with that info.
        if params["booking"]
          bs = BookingServices.new
          booking_authenticated = params["booking"].all? do |booking|
            begin
              service = Service.find(booking["service_id"])
              bs.associate_user(service, @traveler, booking["user_name"], booking["password"])[0]
            rescue => err
              @traveler.errors.messages[:booking] = err.to_s
              false
            end
          end
          booking_message = booking_authenticated ? "Third-party booking profile(s) successfully authenticated." : "Third-party booking authentication failed."
          response[:booking] = {result: booking_authenticated, message: booking_message}
          valid &&= booking_authenticated
        end

        if !valid
          Rails.logger.error(@traveler.errors.messages)
          status = 400
          response[:message] = "Unable to update user profile due the following error: #{@traveler.errors.messages}"
        else
          @traveler.save
          status = 200
          response[:message] = "User updated."
        end

        render json: response, status: status and return
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

      def password

        if params[:password].nil? or params[:password_confirmation].nil?
          render status: 400, json: {result: false, message: "Missing password or password confirmation."}
          return
        end

        if params[:password] != params[:password_confirmation]
          render status: 406, json: {result: false, message: 'Passwords do not match.'}
          return
        end


        @traveler.password = params[:password]
        @traveler.password_confirmation = params[:password_confirmation]

        result = @traveler.save

        if result
          render status: 200, json: {result: result, message: 'Success'}
        else
          render status: 406, json: {result: result, message: 'Unacceptable Password'}
        end

        return
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

      def request_reset
        email = params[:email]
        user = User.find_by(email: email)
        if user.nil?
          render status: 404, json: {message: "User not found"}
          return
        else
          user.send_api_user_reset_password_instructions
          render status: 200, json: {message: "Password reset instructions send to #{email}."}
          return
        end
      end

      def reset

        token = Devise.token_generator.digest(User, :reset_password_token, params[:reset_password_token])
        user = User.find_by_reset_password_token(token)
        unless (user && user.reset_password_period_valid?)
          render status: 403, json: {message: "Invalid password reset token."}
          return
        end

        if params[:password].nil? or params[:password_confirmation].nil?
          render status: 400, json: {result: false, message: "Missing password or password confirmation."}
          return
        end

        if params[:password] != params[:password_confirmation]
          render status: 406, json: {result: false, message: 'Passwords do not match.'}
          return
        end


        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]

        result = user.save

        if result
          render status: 200, json: {result: result, message: 'Success'}
        else
          render status: 406, json: {result: result, message: 'Unacceptable Password'}
        end

        return
      end

    end
  end
end
