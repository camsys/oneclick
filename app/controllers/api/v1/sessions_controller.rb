module Api
  module V1
    class SessionsController < Devise::SessionsController

      # This controller provides a JSON version of the Devise::SessionsController and
      # is compatible with the use of SimpleTokenAuthentication.
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/27

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
          return ecolane_sign_in(external_user_id, dob)
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
            # Note that the data which should be returned depends heavily of the API client needs.
            render status: 200, json: { email: user.email, authentication_token: user.authentication_token}
          else
            render status: 401, json: { message: 'Invalid email or password.' }
          end
        else
          render status: 401, json: { message: 'Invalid email or password.' }
        end
      end

      def ecolane_sign_in(external_user_id, dob)
        eh = EcolaneHelpers.new
        #If the formatting is correct, check to see if this is a valid user
        unless @errors
          result, first_name, last_name = eh.validate_passenger(external_user_id, dob)
          unless result
            render status: 401, json: { message: 'Invalid Ecolane Id or Date of Birth.' }
          end
        end

        #If everything checks out, create a link between the OneClick user and the Booking Service
        @traveler = eh.get_ecolane_traveler(external_user_id, dob, first_name, last_name)
        @traveler.reset_authentication_token!
        render status: 200, json: { email: @traveler.email, authentication_token: @traveler.authentication_token}
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

    end
  end
end