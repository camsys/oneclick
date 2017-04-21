module Api
  module V1
    ## Version 1 of this API makes 2 key assumptions
    ## 1) All bookings are done with via Ecolane
    ## 2) All users are registered to book with only 1 service
    class ApiController < ActionController::Base

      force_ssl if: :ssl_configured?

      def ssl_configured?
        ENV["ENABLE_HTTPS"] == "true"
      end

      respond_to :json
      require 'json'

      before_action :confirm_api_activated
      before_action :confirm_user_token
      before_action :get_api_traveler
      after_filter :set_access_control_headers

      # Catches server errors so that response can be rendered as JSON with proper headers, etc.
      rescue_from Exception, with: :api_error_response

      def handle_options_request
        head(:ok) if request.request_method == "OPTIONS"
      end

      protected

      # Rescues 500 errors and renders them properly as JSON response
      def api_error_response(exception)
        response = {
          error: { type: exception.class.name, message: exception.message }
        }
        render status: 500, json: response
      end


      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
        headers['Access-Control-Allow-Headers'] = 'Content-Type, X-User-Token, X-User-Email'
      end

      def confirm_user_token
        email = request.headers['X-User-Email']
        token = request.headers['X-User-Token']

        if email.nil? and token.nil?
          return
        elsif email and token.nil?
          render json: {status: 401, message: "Please enter a token to continue."}
        else
          user = User.find_by(email: email)
          if user.nil?
            render json: {status: 404, message: "User not found."}
          elsif user.authentication_token != token
            render json: {status: 401, message: "Invalid token."}
          end
        end
      end

      def get_api_traveler
        unless is_visitor_request?
          @traveler = User.find_by(email: request.headers['X-User-Email'])
          Rails.logger.info("Traveler Id: " + @traveler.id.to_s)
        else
          @traveler = User.find_by(api_guest: true)
        end
      end

      def is_visitor_request?
        request.headers["X-User-Email"].nil?
      end

      def confirm_api_activated
        unless Oneclick::Application.config.api_activated
          hash = {status: 401, message: "Calls to this API are not authorized."}
          render json: hash
        end
      end

      def create_guest_user
        random_string = SecureRandom.urlsafe_base64(16)
        u = User.new
        u.first_name = "Visitor"
        u.last_name = "Guest"
        u.password = random_string
        u.email = "guest_#{random_string}@example.com"
        u.save!(:validate => false)
        u.add_role :anonymous_traveler
        session[:guest_user_id] = u.id
        u
      end

    end
  end
end
