module Api
  module V1
    class ApiController < ApplicationController
      respond_to :json
      require 'json'

      before_action :confirm_api_activated

      def confirm_api_activated
        unless Oneclick::Application.config.api_activated
          hash = {status: 401, message: "Calls to this API are not authorized."}
          respond_with hash
        end
      end

    end
  end
end