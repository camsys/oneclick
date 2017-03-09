module Api
  module V1
    class SessionsController < Devise::SessionsController

      # This controller provides a JSON version of the Devise::SessionsController and
      # is compatible with the use of SimpleTokenAuthentication.
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/27

      after_filter :set_access_control_headers

      def create
        email = params[:session][:email] if params[:session]
        password = params[:session][:password] if params[:session]
        external_user_id = params[:session][:ecolane_id] if params[:session]
        dob = params[:session][:dob] if params[:session]

        # Validations
        if request.format != :json
          render status: 406, json: { message: 'The request must be JSON.' }
          return
        end

        if email and password
          return standard_sign_in(email, password)
        elsif external_user_id and dob
          county = params[:session][:county]
          return ecolane_sign_in(external_user_id, dob, county)
        else
          render status: 401, json: { message: 'Invalid Sign in.' }
        end

      end

      def standard_sign_in(email, password)
        # Fetch params

        # Authentication
        user = User.find_by(email: email)

        if user
          if user.valid_password? password
            user.reset_authentication_token!
            user.sign_in_count += 1
            user.save
            # Note that the data which should be returned depends heavily of the API client needs.
            render status: 200, json: { email: user.email, authentication_token: user.authentication_token}
          else
            render status: 401, json: { message: 'Invalid email or password.' }
          end
        else
          render status: 401, json: { message: 'Invalid email or password.' }
        end
      end

      def ecolane_sign_in(external_user_id, dob, county)
        bs = BookingServices.new
        #If the formatting is correct, check to see if this is a valid user
        service = bs.county_to_service county

        result, user_service = bs.associate_user(service, nil, external_user_id, dob)

        unless result
          render status: 401, json: { message: 'Invalid Ecolane Id or Date of Birth.' }
          return
        end

        #If everything checks out, create a link between the OneClick user and the Booking Service
        @traveler = user_service.user_profile.user
        @traveler.reset_authentication_token!
        @traveler.sign_in_count += 1
        @traveler.save

        #Update Age
        @traveler.user_profile.update_age dob

        #Last Trip
        last_trip = @traveler.trips.order('created_at').last
        if last_trip and last_trip.origin and last_trip.destination
          last_origin = last_trip.origin.build_place_details_hash
          last_destination = last_trip.destination.build_place_details_hash
        else
          # Replace the origin below with the user's home address
          home = @traveler.home
          if home
            last_origin = home.build_place_details_hash
          else
            last_origin = nil
          end
          last_destination = nil
        end

        render status: 200, json: { email: @traveler.email, authentication_token: @traveler.authentication_token, first_name: @traveler.first_name, last_name: @traveler.last_name, last_origin: last_origin, last_destination: last_destination}
      end

      def destroy
        # Fetch params
        user = User.find_by(authentication_token: params[:user_token])

        if user.nil?
          render status: 404, json: { message: 'Invalid token.' }
        else
          user.authentication_token = nil
          user.save!
          render status: 204, json: {message: 'Signed out' }
        end
      end

      def sign_up
        email = params[:email]
        first_name = params[:first_name]
        last_name = params[:last_name]
        password = params[:password]
        password_confirmation = params[:password_confirmation]

        new_user = User.new(email: email, first_name: first_name, last_name: last_name, password: password, password_confirmation: password_confirmation)
        if new_user.save
          new_user.reset_authentication_token!
          new_user.sign_in_count += 1
          new_user.add_role :registered_traveler
          new_user.save
          render status: 201, json: {email: new_user.email, authentication_token: new_user.authentication_token}
          return
        else
          render status: 400, json: new_user.errors.messages
          return
        end

      end

      def reset
        email = params[:email]
        user = User.find_by(email: email)
        if user.nil?
          render status: 404, json: {message: "User not found"}
          return
        else
          user.send_reset_password_instructions
          render status: 200, json: {message: "Password reset instructions send to #{email}."}
          return
        end
      end

      def edit

        token = Devise.token_generator.digest(User, :reset_password_token, params[:reset_password_token])
        user = resource_class.find_by_reset_password_token(token)
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

      protected

      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
        headers['Access-Control-Allow-Headers'] = 'Content-Type, X-User-Token, X-User-Email'
      end

    end  # Class
  end #V1
end #API
