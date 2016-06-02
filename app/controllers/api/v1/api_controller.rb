module Api
  module V1
    ## Version 1 of this API makes 2 key assumptions
    ## 1) All bookings are done with via Ecolane
    ## 2) All users are registered to book with only 1 service
    class ApiController < ApplicationController

      respond_to :json
      require 'json'

      skip_before_filter :get_traveler
      before_action :confirm_api_activated
      before_action :confirm_user_token
      before_action :get_api_traveler
      after_filter :set_access_control_headers

      def handle_options_request
        head(:ok) if request.request_method == "OPTIONS"
      end

      protected

      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
        headers['Access-Control-Allow-Headers'] = 'Content-Type'
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
          @traveler = guest_user
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

    end
  end
end